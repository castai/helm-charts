package e2e

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/castai/helm-charts/test/e2e/utils"
)

var _ = Describe("castai-chart-upgrader", Ordered, func() {

	Context("auto-upgrade from previous version", Ordered, func() {
		const (
			kindClusterName    = "castai-chart-upgrader"
			umbrellaRelease    = "castai"
			upgraderRelease    = "castai-chart-upgrader"
			namespace          = "castai-agent"
			upgraderCronjobName = "castai-chart-upgrader"
		)
		var (
			kindHelper       *KindHelper
			namespaceHelper  *NamespaceHelper
			apiKey           string
			installedVersion string
			jobName          string
			upgraderChartPath string
		)

		BeforeAll(func() {
			apiKey = getAPIKey(Default)

			_, thisFile, _, _ := runtime.Caller(0)
			repoRoot := filepath.Join(filepath.Dir(thisFile), "..", "..")
			upgraderChartPath = filepath.Join(repoRoot, "charts", "castai-chart-upgrader")

			kindHelper = NewKindHelper(kindClusterName)
			namespaceHelper = NewNamespaceHelper()

			By(fmt.Sprintf("creating Kind cluster: %s", kindClusterName))
			Expect(kindHelper.Create()).To(Succeed())
			Expect(kindHelper.SetKubeContext()).To(Succeed())
			kindHelper.WaitForReady(Default)
		})

		AfterAll(func() {
			_, _ = utils.Run(exec.Command("helm", "uninstall", upgraderRelease,
				"--namespace", namespace, "--ignore-not-found", "--no-hooks",
				"--timeout", defaultHelmTimeout))
			_, _ = utils.Run(exec.Command("helm", "uninstall", umbrellaRelease,
				"--namespace", namespace, "--ignore-not-found", "--no-hooks",
				"--timeout", defaultHelmTimeout))
			_ = namespaceHelper.Delete(namespace)
			_ = kindHelper.Delete()
		})

		AfterEach(func() {
			if CurrentSpecReport().Failed() {
				collectDebugInfo(namespace)
				if jobName != "" {
					cmd := exec.Command("kubectl", "logs",
						fmt.Sprintf("job/%s", jobName), "-n", namespace)
					output, _ := utils.Run(cmd)
					_, _ = fmt.Fprintf(GinkgoWriter,
						"\n=== Upgrader job logs ===\n%s\n", output)
				}
			}
		})

		It("should resolve the second-to-last umbrella chart version", func() {
			cmd := exec.Command("helm", "search", "repo",
				"castai-helm/castai", "--versions", "-o", "json")
			output, err := utils.Run(cmd)
			Expect(err).NotTo(HaveOccurred())

			var results []struct {
				Name    string `json:"name"`
				Version string `json:"version"`
			}
			Expect(json.Unmarshal([]byte(strings.TrimSpace(output)), &results)).To(Succeed())
			Expect(len(results)).To(BeNumerically(">=", 2),
				"need at least 2 published versions")

			installedVersion = results[1].Version
			_, _ = fmt.Fprintf(GinkgoWriter,
				"Latest: %s, Installing: %s\n",
				results[0].Version, installedVersion)
		})

		It("should install the second-to-last umbrella version (autoscaler-anywhere)", func() {
			Expect(installedVersion).NotTo(BeEmpty())
			cmd := exec.Command("helm", "upgrade", "--install", umbrellaRelease,
				"castai-helm/castai",
				"--version", installedVersion,
				"--namespace", namespace,
				"--create-namespace",
				"--set", "tags.autoscaler-anywhere=true",
				"--set", "autoscaler-anywhere.castai-agent.additionalEnv.ANYWHERE_CLUSTER_NAME=e2e-upgrader",
				"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
				"--set", fmt.Sprintf("global.castai.apiURL=%s", apiURL),
				"--timeout", "10m",
			)
			_, err := utils.Run(cmd)
			Expect(err).NotTo(HaveOccurred())
		})

		It("should have the umbrella release deployed at the installed version", func() {
			Eventually(func(g Gomega) {
				chart := getReleaseChartVersion(g, umbrellaRelease, namespace)
				g.Expect(chart).To(ContainSubstring(installedVersion))
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should install the chart-upgrader targeting the umbrella release", func() {
			cmd := exec.Command("helm", "upgrade", "--install", upgraderRelease,
				upgraderChartPath,
				"--namespace", namespace,
				"--set", fmt.Sprintf("targetRelease=%s", umbrellaRelease),
				"--set", "chart.name=castai",
				"--set", "schedule=0 0 1 1 *",
				"--set", "upgrade.atomic=true",
				"--set", "upgrade.wait=true",
				"--set", "upgrade.timeout=10m",
				"--timeout", defaultHelmTimeout,
			)
			_, err := utils.Run(cmd)
			Expect(err).NotTo(HaveOccurred())
		})

		It("should have the chart-upgrader CronJob", func() {
			Eventually(func(g Gomega) {
				cmd := exec.Command("kubectl", "get", "cronjob", upgraderCronjobName,
					"-n", namespace, "-o", "name")
				output, err := utils.Run(cmd)
				g.Expect(err).NotTo(HaveOccurred())
				g.Expect(output).To(ContainSubstring(upgraderCronjobName))
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should trigger the upgrade job", func() {
			jobName = fmt.Sprintf("test-upgrade-%d", time.Now().Unix())
			cmd := exec.Command("kubectl", "create", "job",
				"--from", fmt.Sprintf("cronjob/%s", upgraderCronjobName),
				jobName, "-n", namespace)
			_, err := utils.Run(cmd)
			Expect(err).NotTo(HaveOccurred())
		})

		It("should complete the upgrade job successfully", func() {
			Expect(jobName).NotTo(BeEmpty())

			Eventually(func(g Gomega) {
				cmd := exec.Command("kubectl", "get", "job", jobName,
					"-n", namespace,
					"-o", "jsonpath={.status.conditions[?(@.type==\"Complete\")].status}")
				output, err := utils.Run(cmd)
				g.Expect(err).NotTo(HaveOccurred())
				g.Expect(strings.TrimSpace(output)).To(Equal("True"))
			}, 15*time.Minute, 15*time.Second).Should(Succeed())
		})

		It("should have upgraded the umbrella release to a newer version", func() {
			release := getReleaseInfo(Default, umbrellaRelease, namespace)
			Expect(release.Chart).NotTo(ContainSubstring(installedVersion),
				"release should have been upgraded from "+installedVersion)
			Expect(release.Status).To(Equal("deployed"))

			_, _ = fmt.Fprintf(GinkgoWriter,
				"Upgraded from castai-%s to %s\n",
				installedVersion, release.Chart)
		})
	})
})

type releaseInfo struct {
	Status string
	Chart  string
}

func getReleaseInfo(g Gomega, releaseName, namespace string) releaseInfo {
	cmd := exec.Command("helm", "list", "-n", namespace,
		"--filter", fmt.Sprintf("^%s$", releaseName), "-o", "json")
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred())

	var releases []struct {
		Status string `json:"status"`
		Chart  string `json:"chart"`
	}
	g.Expect(json.Unmarshal([]byte(strings.TrimSpace(output)), &releases)).To(Succeed())
	g.Expect(releases).To(HaveLen(1))

	return releaseInfo{Status: releases[0].Status, Chart: releases[0].Chart}
}

func getReleaseChartVersion(g Gomega, releaseName, namespace string) string {
	info := getReleaseInfo(g, releaseName, namespace)
	g.Expect(info.Status).To(Equal("deployed"))
	return info.Chart
}
