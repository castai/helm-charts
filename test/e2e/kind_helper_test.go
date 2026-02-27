package e2e

import (
	"fmt"
	"os/exec"
	"strings"
	"time"

	. "github.com/onsi/gomega"

	"github.com/castai/helm-charts/test/e2e/utils"
)

// KindHelper manages the lifecycle of a Kind cluster used in e2e tests.
type KindHelper struct {
	clusterName string
}

func NewKindHelper(clusterName string) *KindHelper {
	return &KindHelper{clusterName: clusterName}
}

// Create creates a Kind cluster, deleting any existing one with the same name first.
func (k *KindHelper) Create() error {
	_ = k.Delete()
	cmd := exec.Command("kind", "create", "cluster",
		"--name", k.clusterName,
		"--wait", "5m",
	)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("failed to create kind cluster %s: %w", k.clusterName, err)
	}
	return nil
}

// Delete tears down the Kind cluster. Returns nil if it does not exist.
func (k *KindHelper) Delete() error {
	cmd := exec.Command("kind", "delete", "cluster", "--name", k.clusterName)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("failed to delete kind cluster %s: %w", k.clusterName, err)
	}
	return nil
}

// SetKubeContext switches kubectl to this Kind cluster's context.
func (k *KindHelper) SetKubeContext() error {
	contextName := fmt.Sprintf("kind-%s", k.clusterName)
	cmd := exec.Command("kubectl", "config", "use-context", contextName)
	_, err := utils.Run(cmd)
	if err != nil {
		return fmt.Errorf("failed to switch kube context to %s: %w", contextName, err)
	}
	return nil
}

// WaitForReady blocks until all nodes in the cluster report Ready.
func (k *KindHelper) WaitForReady(g Gomega) {
	verifyNodesReady := func(g Gomega) {
		// Use --no-headers and custom-columns to avoid jsonpath newline quoting issues.
		cmd := exec.Command("kubectl", "get", "nodes",
			"--no-headers",
			"-o", "custom-columns=STATUS:.status.conditions[-1].status",
		)
		output, err := utils.Run(cmd)
		g.Expect(err).NotTo(HaveOccurred(), "Failed to get node status")
		lines := utils.GetNonEmptyLines(output)
		g.Expect(lines).NotTo(BeEmpty(), "No nodes found in cluster")
		for _, line := range lines {
			g.Expect(strings.TrimSpace(line)).To(Equal("True"), "Node is not Ready")
		}
	}
	Eventually(verifyNodesReady, 5*time.Minute, 5*time.Second).Should(Succeed())
}
