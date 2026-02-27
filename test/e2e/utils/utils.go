package utils

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"

	. "github.com/onsi/ginkgo/v2"
)

// Run executes the given command, prints it to GinkgoWriter, and returns
// the combined stdout+stderr output as a string. It returns an error if the
// command exits with a non-zero status.
func Run(cmd *exec.Cmd) (string, error) {
	_, _ = fmt.Fprintf(GinkgoWriter, "Running: %s\n", strings.Join(cmd.Args, " "))

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	combined := stdout.String() + stderr.String()

	if err != nil {
		_, _ = fmt.Fprintf(GinkgoWriter, "Command failed: %v\nOutput:\n%s\n", err, combined)
		return combined, fmt.Errorf("command %q failed: %w\nOutput: %s", strings.Join(cmd.Args, " "), err, combined)
	}

	_, _ = fmt.Fprintf(GinkgoWriter, "Output:\n%s\n", combined)
	return combined, nil
}

// GetNonEmptyLines splits a string by newlines and returns only non-empty lines,
// with leading/trailing whitespace trimmed from each line.
func GetNonEmptyLines(output string) []string {
	var lines []string
	for _, line := range strings.Split(output, "\n") {
		trimmed := strings.TrimSpace(line)
		if trimmed != "" {
			lines = append(lines, trimmed)
		}
	}
	return lines
}
