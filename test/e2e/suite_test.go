package e2e

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/castai/helm-charts/test/e2e/utils"
)

const (
	defaultAPIURL = "https://api.dev-master.cast.ai"
)

var apiURL string
var chartPath string

func TestE2E(t *testing.T) {
	RegisterFailHandler(Fail)
	_, _ = fmt.Fprintf(GinkgoWriter, "Starting castai-umbrella e2e test suite\n")
	RunSpecs(t, "castai-umbrella e2e suite")
}

var _ = BeforeSuite(func() {
	apiURL = os.Getenv("API_URL")
	if apiURL == "" {
		apiURL = defaultAPIURL
	}
	_, _ = fmt.Fprintf(GinkgoWriter, "Using Cast AI API URL: %s\n", apiURL)

	// Resolve local chart path: test/e2e/ -> ../../charts/castai-umbrella
	_, thisFile, _, _ := runtime.Caller(0)
	repoRoot := filepath.Join(filepath.Dir(thisFile), "..", "..")
	chartPath = filepath.Join(repoRoot, "charts", "castai-umbrella")
	_, _ = fmt.Fprintf(GinkgoWriter, "Using chart path: %s\n", chartPath)

	By("ensuring kind is available")
	_, err := utils.Run(exec.Command("kind", "version"))
	ExpectWithOffset(1, err).NotTo(HaveOccurred(), "kind must be installed")

	By("ensuring helm is available")
	_, err = utils.Run(exec.Command("helm", "version"))
	ExpectWithOffset(1, err).NotTo(HaveOccurred(), "helm must be installed")

	By("ensuring kubectl is available")
	_, err = utils.Run(exec.Command("kubectl", "version", "--client"))
	ExpectWithOffset(1, err).NotTo(HaveOccurred(), "kubectl must be installed")

	By("adding castai-helm repo")
	_, _ = utils.Run(exec.Command("helm", "repo", "add", "castai-helm", "https://castai.github.io/helm-charts"))

	By("updating helm repos")
	_, err = utils.Run(exec.Command("helm", "repo", "update", "castai-helm"))
	ExpectWithOffset(1, err).NotTo(HaveOccurred(), "Failed to update helm repos")

	for _, subChart := range []string{"kent", "autoscaler"} {
		p := filepath.Join(repoRoot, "charts", "castai-umbrella", "charts", subChart)
		if _, statErr := os.Stat(p); statErr == nil {
			By(fmt.Sprintf("running helm dependency update on %s subchart", subChart))
			_, err = utils.Run(exec.Command("helm", "dependency", "update", p))
			ExpectWithOffset(1, err).NotTo(HaveOccurred(), "Failed to update "+subChart+" subchart deps")
		}
	}

	By("running helm dependency update on umbrella chart")
	_, err = utils.Run(exec.Command("helm", "dependency", "update", chartPath))
	ExpectWithOffset(1, err).NotTo(HaveOccurred(), "Failed to update umbrella chart deps")
})

var _ = AfterSuite(func() {})

func getAPIKey(g Gomega) string {
	apiKey := os.Getenv("CASTAI_API_KEY")
	g.Expect(apiKey).NotTo(BeEmpty(), "CASTAI_API_KEY environment variable must be set")
	return apiKey
}
