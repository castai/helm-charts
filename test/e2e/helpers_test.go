package e2e

import (
	"fmt"
	"os/exec"
	"strings"
	"time"

	. "github.com/onsi/gomega"

	"github.com/castai/helm-charts/test/e2e/utils"
)

const (
	defaultHelmTimeout = "5m"
)

type UmbrellaHelmHelper struct {
	namespace   string
	releaseName string
	apiURL      string
}

func NewUmbrellaHelmHelper(releaseName, namespace, apiURL string) *UmbrellaHelmHelper {
	return &UmbrellaHelmHelper{namespace: namespace, releaseName: releaseName, apiURL: apiURL}
}

func (h *UmbrellaHelmHelper) InstallKentMode(apiKey string) error {
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "kent.enabled=true",
		"--set", "kent.agent.enabled=true",
		"--set", "kent.kentroller.enabled=true",
		"--set", "kent.cluster-controller.enabled=true",
		"--set", "kent.evictor.enabled=true",
		"--set", "kent.live.enabled=false",
		"--set", "kent.pod-mutator.enabled=false",
		"--set", "kent.workload-autoscaler.enabled=false",
		"--set", "kent.metrics-server.enabled=false",
		"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
		"--set", fmt.Sprintf("global.castai.apiURL=%s", h.apiURL),
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm install kent mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) InstallAutoscalerMode(apiKey, provider string) error {
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "autoscaler.enabled=true",
		"--set", "autoscaler.agent.enabled=true",
		"--set", "autoscaler.cluster-controller.enabled=true",
		"--set", "autoscaler.evictor.enabled=true",
		"--set", "autoscaler.live.enabled=false",
		"--set", "autoscaler.pod-mutator.enabled=false",
		"--set", "autoscaler.workload-autoscaler.enabled=false",
		"--set", "autoscaler.metrics-server.enabled=false",
		"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
		"--set", fmt.Sprintf("global.castai.apiURL=%s", h.apiURL),
		"--set", fmt.Sprintf("global.castai.provider=%s", provider),
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm install autoscaler mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) Uninstall() error {
	cmd := exec.Command("helm", "uninstall", h.releaseName,
		"--namespace", h.namespace,
		"--ignore-not-found",
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm uninstall %s failed: %w", h.releaseName, err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) VerifyReleaseInstalled(g Gomega) {
	cmd := exec.Command("helm", "list", "--namespace", h.namespace, "--filter", h.releaseName, "-o", "json")
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred())
	g.Expect(output).To(ContainSubstring(h.releaseName))
	g.Expect(output).To(ContainSubstring(`"status":"deployed"`))
}

func (h *UmbrellaHelmHelper) VerifyNoRelease(g Gomega) {
	cmd := exec.Command("helm", "list", "--namespace", h.namespace, "--filter", h.releaseName, "-o", "json")
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred())
	g.Expect(output).To(Or(Equal(""), Equal("[]\n"), Equal("[]")))
}

func (h *UmbrellaHelmHelper) GetReleaseValues() (string, error) {
	cmd := exec.Command("helm", "get", "values", h.releaseName, "--namespace", h.namespace, "-o", "json")
	output, err := utils.Run(cmd)
	if err != nil {
		return "", fmt.Errorf("failed to get values for release %s: %w", h.releaseName, err)
	}
	return strings.TrimSpace(output), nil
}

// PodHelper checks deployment/daemonset existence by NAME (not label) in a namespace.
// We use name-based lookup because castai charts don't consistently use
// app.kubernetes.io/name labels — the deployment name is the reliable identifier.
type PodHelper struct {
	namespace string
}

func NewPodHelper(namespace string) *PodHelper {
	return &PodHelper{namespace: namespace}
}

// VerifyDeploymentExists checks a deployment with the given name exists.
func (p *PodHelper) VerifyDeploymentExists(g Gomega, deploymentName string) {
	cmd := exec.Command("kubectl", "get", "deployment", deploymentName,
		"-n", p.namespace, "-o", "name")
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred(),
		fmt.Sprintf("Deployment %s should exist in namespace %s", deploymentName, p.namespace))
	g.Expect(output).To(ContainSubstring(deploymentName))
}

// VerifyDeploymentAbsent checks that NO deployment with the given name exists.
func (p *PodHelper) VerifyDeploymentAbsent(g Gomega, deploymentName string) {
	cmd := exec.Command("kubectl", "get", "deployment", deploymentName,
		"-n", p.namespace, "-o", "name")
	_, err := utils.Run(cmd)
	g.Expect(err).To(HaveOccurred(),
		fmt.Sprintf("Deployment %s should NOT exist", deploymentName))
}

// VerifySecretExists checks that a secret with the given name exists.
func (p *PodHelper) VerifySecretExists(g Gomega, secretName string) {
	cmd := exec.Command("kubectl", "get", "secret", secretName,
		"-n", p.namespace, "-o", "name")
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred(), fmt.Sprintf("Secret %s should exist", secretName))
	g.Expect(output).To(ContainSubstring(secretName))
}

type NamespaceHelper struct{}

func NewNamespaceHelper() *NamespaceHelper { return &NamespaceHelper{} }

func (n *NamespaceHelper) Delete(namespace string) error {
	cmd := exec.Command("kubectl", "delete", "ns", namespace, "--ignore-not-found", "--timeout=2m")
	_, err := utils.Run(cmd)
	return err
}

func (n *NamespaceHelper) VerifyDeleted(g Gomega, namespace string) {
	cmd := exec.Command("kubectl", "get", "ns", namespace)
	_, err := utils.Run(cmd)
	g.Expect(err).To(HaveOccurred(), fmt.Sprintf("Namespace %s should not exist", namespace))
}

func (n *NamespaceHelper) VerifyExists(g Gomega, namespace string) {
	cmd := exec.Command("kubectl", "get", "ns", namespace)
	_, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred(), fmt.Sprintf("Namespace %s should exist", namespace))
}

func waitForDeployment(podHelper *PodHelper, name string, timeout time.Duration) {
	Eventually(func(g Gomega) {
		podHelper.VerifyDeploymentExists(g, name)
	}, timeout, 5*time.Second).Should(Succeed())
}

// VerifyAtLeastOnePodReady checks that the named deployment has at least one
// available replica according to the deployment status — no label guessing needed.
func (p *PodHelper) VerifyAtLeastOnePodReady(g Gomega, deploymentName string) {
	cmd := exec.Command("kubectl", "get", "deployment", deploymentName,
		"-n", p.namespace,
		"-o", "jsonpath={.status.availableReplicas}",
	)
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred(),
		fmt.Sprintf("Failed to get deployment %s status", deploymentName))
	available := strings.TrimSpace(output)
	g.Expect(available).NotTo(BeEmpty(),
		fmt.Sprintf("Deployment %s has no availableReplicas field yet", deploymentName))
	g.Expect(available).NotTo(Equal("0"),
		fmt.Sprintf("Deployment %s has 0 available replicas", deploymentName))
}

// VerifyAgentConnected waits until the castai-agent has successfully registered
// with mothership. The agent creates the castai-agent-metadata ConfigMap only
// after receiving a cluster ID from the API — so its existence proves connectivity.
func (p *PodHelper) VerifyAgentConnected(g Gomega) {
	cmd := exec.Command("kubectl", "get", "configmap", "castai-agent-metadata",
		"-n", p.namespace,
		"-o", "name",
	)
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred(),
		"castai-agent-metadata configmap not found — agent has not registered with mothership yet")
	g.Expect(output).To(ContainSubstring("castai-agent-metadata"))
}
