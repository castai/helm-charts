package e2e

import (
	"fmt"
	"os/exec"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/castai/helm-charts/test/e2e/utils"
)

const umbrellaNamespace = "castai-agent"

var _ = Describe("castai-umbrella helm chart", Ordered, func() {

	// -----------------------------------------------------------------------
	// Kent mode
	// -----------------------------------------------------------------------
	Context("kent mode", Ordered, func() {
		const (
			kindClusterName = "castai-umbrella-kent"
			releaseName     = "castai-kent"
		)
		var (
			kindHelper      *KindHelper
			helmHelper      *UmbrellaHelmHelper
			podHelper       *PodHelper
			namespaceHelper *NamespaceHelper
			apiKey          string
		)

		BeforeAll(func() {
			verifyAPIKey := func(g Gomega) { apiKey = getAPIKey(g) }
			verifyAPIKey(Default)
			kindHelper = NewKindHelper(kindClusterName)
			helmHelper = NewUmbrellaHelmHelper(releaseName, umbrellaNamespace, apiURL)
			podHelper = NewPodHelper(umbrellaNamespace)
			namespaceHelper = NewNamespaceHelper()
			By(fmt.Sprintf("creating Kind cluster: %s", kindClusterName))
			Expect(kindHelper.Create()).To(Succeed())
			Expect(kindHelper.SetKubeContext()).To(Succeed())
			kindHelper.WaitForReady(Default)
		})

		AfterAll(func() {
			_ = helmHelper.Uninstall()
			_ = namespaceHelper.Delete(umbrellaNamespace)
			_ = kindHelper.Delete()
		})

		AfterEach(func() {
			if CurrentSpecReport().Failed() {
				collectDebugInfo(umbrellaNamespace)
			}
		})

		It("should install successfully in kent mode", func() {
			Expect(helmHelper.InstallKentMode(apiKey)).To(Succeed())
		})

		It("should have the release in deployed status", func() {
			Eventually(helmHelper.VerifyReleaseInstalled, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should log all resources created by the chart (discovery)", func() {
			discoverChartResources()
		})

		It("should create the castai-agent namespace", func() {
			namespaceHelper.VerifyExists(Default, umbrellaNamespace)
		})

		It("should create the castai-credentials secret", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifySecretExists(g, "castai-credentials")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should create the castai-agent deployment", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyDeploymentExists(g, "castai-agent")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should create the castai-kentroller deployment", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyDeploymentExists(g, "castai-kentroller")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should create the castai-cluster-controller deployment", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyDeploymentExists(g, "castai-cluster-controller")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should have castai-agent registered with mothership", func() {
			By("patching castai-agent with fake EKS env vars so it can register with mothership")
			Expect(patchAgentForE2E(umbrellaNamespace, apiURL)).To(Succeed())

			By("waiting for castai-agent to register — configmap is created only after successful registration")
			Eventually(func(g Gomega) {
				podHelper.VerifyAgentConnected(g)
			}, 10*time.Minute, 10*time.Second).Should(Succeed())
		})

		It("should have castai-agent pod running and ready", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyAtLeastOnePodReady(g, "castai-agent")
			}, 5*time.Minute, 10*time.Second).Should(Succeed())
		})

		// castai-kentroller requires Karpenter CRDs (karpenter.sh/v1 NodePool) which
		// don't exist in Kind — it crashes immediately. Pod readiness for kentroller
		// is only meaningful on a real EKS cluster with Karpenter installed.

		It("should have castai-cluster-controller pod running and ready", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyAtLeastOnePodReady(g, "castai-cluster-controller")
			}, 5*time.Minute, 10*time.Second).Should(Succeed())
		})

		It("should NOT create workload-autoscaler in kent mode", func() {
			podHelper.VerifyDeploymentAbsent(Default, "castai-workload-autoscaler")
		})

		It("should have kent config in release values", func() {
			values, err := helmHelper.GetReleaseValues()
			Expect(err).NotTo(HaveOccurred())
			Expect(values).To(ContainSubstring("kent"))
		})
	})

	// -----------------------------------------------------------------------
	// Autoscaler mode
	// -----------------------------------------------------------------------
	Context("autoscaler mode", Ordered, func() {
		const (
			kindClusterName = "castai-umbrella-autoscaler"
			releaseName     = "castai-auto"
			provider        = "aws"
		)
		var (
			kindHelper      *KindHelper
			helmHelper      *UmbrellaHelmHelper
			podHelper       *PodHelper
			namespaceHelper *NamespaceHelper
			apiKey          string
		)

		BeforeAll(func() {
			verifyAPIKey := func(g Gomega) { apiKey = getAPIKey(g) }
			verifyAPIKey(Default)
			kindHelper = NewKindHelper(kindClusterName)
			helmHelper = NewUmbrellaHelmHelper(releaseName, umbrellaNamespace, apiURL)
			podHelper = NewPodHelper(umbrellaNamespace)
			namespaceHelper = NewNamespaceHelper()
			By(fmt.Sprintf("creating Kind cluster: %s", kindClusterName))
			Expect(kindHelper.Create()).To(Succeed())
			Expect(kindHelper.SetKubeContext()).To(Succeed())
			kindHelper.WaitForReady(Default)
		})

		AfterAll(func() {
			_ = helmHelper.Uninstall()
			_ = namespaceHelper.Delete(umbrellaNamespace)
			_ = kindHelper.Delete()
		})

		AfterEach(func() {
			if CurrentSpecReport().Failed() {
				collectDebugInfo(umbrellaNamespace)
			}
		})

		It("should install successfully in autoscaler mode", func() {
			Expect(helmHelper.InstallAutoscalerMode(apiKey, provider)).To(Succeed())
		})

		It("should have the release in deployed status", func() {
			Eventually(helmHelper.VerifyReleaseInstalled, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should log all resources created by the chart (discovery)", func() {
			discoverChartResources()
		})

		It("should create the castai-agent namespace", func() {
			namespaceHelper.VerifyExists(Default, umbrellaNamespace)
		})

		It("should create the castai-credentials secret", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifySecretExists(g, "castai-credentials")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should create the castai-agent deployment", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyDeploymentExists(g, "castai-agent")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should create the castai-cluster-controller deployment", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyDeploymentExists(g, "castai-cluster-controller")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should create the castai-evictor deployment", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyDeploymentExists(g, "castai-evictor")
			}, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should have castai-agent registered with mothership", func() {
			By("patching castai-agent with fake EKS env vars (provider=aws) so it can register")
			Expect(patchAgentForE2E(umbrellaNamespace, apiURL)).To(Succeed())

			By("waiting for castai-agent to register — configmap is created only after successful registration")
			Eventually(func(g Gomega) {
				podHelper.VerifyAgentConnected(g)
			}, 10*time.Minute, 10*time.Second).Should(Succeed())
		})

		It("should have castai-agent pod running and ready", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyAtLeastOnePodReady(g, "castai-agent")
			}, 5*time.Minute, 10*time.Second).Should(Succeed())
		})

		It("should have castai-cluster-controller pod running and ready", func() {
			Eventually(func(g Gomega) {
				podHelper.VerifyAtLeastOnePodReady(g, "castai-cluster-controller")
			}, 5*time.Minute, 10*time.Second).Should(Succeed())
		})

		// castai-evictor crashes in Kind without Karpenter CRDs and live.cast.ai CRDs.
		// Deployment existence is verified above; pod readiness requires real infrastructure.

		It("should NOT create kent-only kentroller in autoscaler mode", func() {
			podHelper.VerifyDeploymentAbsent(Default, "castai-kentroller")
		})

		It("should have autoscaler config in release values", func() {
			values, err := helmHelper.GetReleaseValues()
			Expect(err).NotTo(HaveOccurred())
			Expect(values).To(ContainSubstring("autoscaler"))
		})

		It("should have the correct provider in release values", func() {
			values, err := helmHelper.GetReleaseValues()
			Expect(err).NotTo(HaveOccurred())
			Expect(values).To(ContainSubstring(provider))
		})
	})

	// -----------------------------------------------------------------------
	// Uninstall
	// -----------------------------------------------------------------------
	Context("clean uninstall", Ordered, func() {
		const (
			kindClusterName = "castai-umbrella-uninstall"
			releaseName     = "castai-uninstall"
		)
		var (
			kindHelper      *KindHelper
			helmHelper      *UmbrellaHelmHelper
			namespaceHelper *NamespaceHelper
			apiKey          string
		)

		BeforeAll(func() {
			verifyAPIKey := func(g Gomega) { apiKey = getAPIKey(g) }
			verifyAPIKey(Default)
			kindHelper = NewKindHelper(kindClusterName)
			helmHelper = NewUmbrellaHelmHelper(releaseName, umbrellaNamespace, apiURL)
			namespaceHelper = NewNamespaceHelper()
			By(fmt.Sprintf("creating Kind cluster: %s", kindClusterName))
			Expect(kindHelper.Create()).To(Succeed())
			Expect(kindHelper.SetKubeContext()).To(Succeed())
			kindHelper.WaitForReady(Default)
		})

		AfterAll(func() {
			_ = kindHelper.Delete()
		})

		It("should install in autoscaler mode", func() {
			Expect(helmHelper.InstallAutoscalerMode(apiKey, "aws")).To(Succeed())
		})

		It("should uninstall cleanly", func() {
			Expect(helmHelper.Uninstall()).To(Succeed())
		})

		It("should have no helm release after uninstall", func() {
			Eventually(helmHelper.VerifyNoRelease, 2*time.Minute, 5*time.Second).Should(Succeed())
		})

		It("should be able to delete the namespace after uninstall", func() {
			Expect(namespaceHelper.Delete(umbrellaNamespace)).To(Succeed())
			Eventually(func(g Gomega) {
				namespaceHelper.VerifyDeleted(g, umbrellaNamespace)
			}, 3*time.Minute, 5*time.Second).Should(Succeed())
		})
	})
})

// patchAgentForE2E sets the EKS cloud metadata env vars on the castai-agent
// deployment and overrides API_URL to point at the test environment.
//
// We use "kubectl set env" instead of a strategic merge patch because the chart
// already sets API_URL — a strategic merge patch would append a duplicate entry
// and the chart-defined value (api.cast.ai) would take precedence. "kubectl set env"
// correctly replaces existing env var values.
func patchAgentForE2E(namespace, apiURL string) error {
	cmd := exec.Command("kubectl", "set", "env", "deployment/castai-agent",
		"-n", namespace,
		"EKS_ACCOUNT_ID=000000000000",
		"EKS_REGION=us-east-1",
		"EKS_CLUSTER_NAME=e2e-kind-cluster",
		fmt.Sprintf("API_URL=%s", apiURL),
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("failed to set agent env vars: %w", err)
	}
	return nil
}

func discoverChartResources() {
	cmds := [][]string{
		{"kubectl", "get", "all", "--all-namespaces"},
		{"kubectl", "get", "deployments", "-n", umbrellaNamespace, "--show-labels"},
		{"kubectl", "get", "secrets", "-n", umbrellaNamespace},
	}
	_, _ = fmt.Fprintf(GinkgoWriter, "\n========== CHART RESOURCE DISCOVERY ==========\n")
	for _, args := range cmds {
		cmd := exec.Command(args[0], args[1:]...)
		output, err := utils.Run(cmd)
		if err != nil {
			_, _ = fmt.Fprintf(GinkgoWriter, "\n$ %s\n[error: %v]\n", joinArgs(args), err)
		} else {
			_, _ = fmt.Fprintf(GinkgoWriter, "\n$ %s\n%s\n", joinArgs(args), output)
		}
	}
	_, _ = fmt.Fprintf(GinkgoWriter, "==============================================\n")
}

func collectDebugInfo(namespace string) {
	cmds := [][]string{
		{"kubectl", "get", "pods", "-n", namespace, "-o", "wide"},
		{"kubectl", "get", "deployments", "-n", namespace},
		{"kubectl", "get", "events", "-n", namespace, "--sort-by=.lastTimestamp"},
		{"helm", "list", "-n", namespace},
		{"kubectl", "get", "all", "--all-namespaces"},
	}
	for _, args := range cmds {
		cmd := exec.Command(args[0], args[1:]...)
		output, err := utils.Run(cmd)
		if err != nil {
			_, _ = fmt.Fprintf(GinkgoWriter, "\n$ %s\n[error: %v]\n", joinArgs(args), err)
		} else {
			_, _ = fmt.Fprintf(GinkgoWriter, "\n$ %s\n%s\n", joinArgs(args), output)
		}
	}
}

func joinArgs(args []string) string {
	s := ""
	for i, a := range args {
		if i > 0 {
			s += " "
		}
		s += a
	}
	return s
}
