package e2e

import (
	"fmt"
	"os/exec"
	"strings"

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
	// preflight checks for Karpenter deployment + CRDs which don't exist on Kind.
	// castai-aws-vpc-cni runs a pre-install hook that patches the aws-node daemonset,
	// which also doesn't exist on Kind.
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "kent.enabled=true",
		"--set", "kent.preflight.enabled=false",
		"--set", "kent.castai-live.castai-aws-vpc-cni.enabled=false",
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

func (h *UmbrellaHelmHelper) InstallAutoscalerReadonlyMode(apiKey, provider string) error {
	// readonly tag activates: castai-agent, castai-spot-handler, castai-kvisor, gpu-metrics-exporter.
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "tags.readonly=true",
		"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
		"--set", fmt.Sprintf("global.castai.apiURL=%s", h.apiURL),
		"--set", fmt.Sprintf("global.castai.provider=%s", provider),
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm install autoscaler readonly mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) UpgradeToFullMode() error {
	// Swap readonly tag for full. --reuse-values preserves apiKey/apiURL/provider.
	// readonly → full is not an additive path so both tags must be set explicitly.
	cmd := exec.Command("helm", "upgrade", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--reuse-values",
		"--set", "tags.readonly=false",
		"--set", "tags.full=true",
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm upgrade to full mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) InstallAutoscalerWorkloadMode(apiKey, provider string) error {
	// workload-autoscaler tag activates: castai-agent, castai-spot-handler, castai-kvisor,
	// gpu-metrics-exporter, castai-cluster-controller, castai-evictor, castai-pod-mutator,
	// castai-workload-autoscaler, castai-workload-autoscaler-exporter.
	// NOT included: castai-pod-pinner, castai-live (those are node-autoscaler + full only).
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "tags.workload-autoscaler=true",
		"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
		"--set", fmt.Sprintf("global.castai.apiURL=%s", h.apiURL),
		"--set", fmt.Sprintf("global.castai.provider=%s", provider),
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm install autoscaler workload mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) InstallAutoscalerMode(apiKey, provider string) error {
	// node-autoscaler tag activates: castai-agent, castai-spot-handler, castai-kvisor,
	// gpu-metrics-exporter, castai-cluster-controller, castai-evictor, castai-pod-mutator,
	// castai-pod-pinner, castai-live (see autoscaler/Chart.yaml tag definitions).
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "tags.node-autoscaler=true",
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

func (h *UmbrellaHelmHelper) InstallAutoscalerAnywhereMode(apiKey, clusterName string) error {
	// tags.autoscaler-anywhere includes the autoscaler-anywhere sub-chart.
	// Components within that sub-chart are enabled by default in its values.yaml;
	// ANYWHERE_CLUSTER_NAME is passed via additionalEnv so the agent can register.
	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "tags.autoscaler-anywhere=true",
		"--set", fmt.Sprintf("autoscaler-anywhere.castai-agent.additionalEnv.ANYWHERE_CLUSTER_NAME=%s", clusterName),
		"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
		"--set", fmt.Sprintf("global.castai.apiURL=%s", h.apiURL),
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm install autoscaler-anywhere mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) InstallAutoscalerOpenshiftMode(apiKey string) error {
	_, _ = utils.Run(exec.Command("kubectl", "create", "namespace", "openshift-machine-api"))

	cmd := exec.Command("helm", "upgrade", "--install", h.releaseName,
		chartPath,
		"--namespace", h.namespace,
		"--create-namespace",
		"--set", "tags.autoscaler-openshift=true",
		"--set", "autoscaler-openshift.castai-agent.enabled=true",
		"--set", fmt.Sprintf("global.castai.apiKey=%s", apiKey),
		"--set", fmt.Sprintf("global.castai.apiURL=%s", h.apiURL),
		"--timeout", defaultHelmTimeout,
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("helm install autoscaler-openshift mode failed: %w", err)
	}
	return nil
}

func (h *UmbrellaHelmHelper) Uninstall() error {
	// --no-hooks skips pre/post-delete hooks (e.g. webhook teardown calls) that
	// block when pods are unhealthy. The namespace and Kind cluster are deleted
	// immediately after, so hook-managed resources are cleaned up anyway.
	cmd := exec.Command("helm", "uninstall", h.releaseName,
		"--namespace", h.namespace,
		"--ignore-not-found",
		"--no-hooks",
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

// VerifyDaemonSetExists checks a daemonset with the given name exists.
func (p *PodHelper) VerifyDaemonSetExists(g Gomega, daemonSetName string) {
	cmd := exec.Command("kubectl", "get", "daemonset", daemonSetName,
		"-n", p.namespace, "-o", "name")
	output, err := utils.Run(cmd)
	g.Expect(err).NotTo(HaveOccurred(),
		fmt.Sprintf("DaemonSet %s should exist in namespace %s", daemonSetName, p.namespace))
	g.Expect(output).To(ContainSubstring(daemonSetName))
}

// VerifyDaemonSetAbsent checks that NO daemonset with the given name exists.
func (p *PodHelper) VerifyDaemonSetAbsent(g Gomega, daemonSetName string) {
	cmd := exec.Command("kubectl", "get", "daemonset", daemonSetName,
		"-n", p.namespace, "-o", "name")
	_, err := utils.Run(cmd)
	g.Expect(err).To(HaveOccurred(),
		fmt.Sprintf("DaemonSet %s should NOT exist", daemonSetName))
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
