package datadir

import (
	"os"
	"path/filepath"

	"github.com/k3s-io/k3s/pkg/version"
	"github.com/pkg/errors"
	"github.com/rancher/wrangler/pkg/resolvehome"
)

var (
	DefaultDataDir     = "/mnt/user/0/emulated/0/k3s/var/lib/rancher/" + version.Program
	DefaultHomeDataDir = "/mnt/user/0/emulated/0/k3s/rancher/" + version.Program
	HomeConfig         = "/mnt/user/0/emulated/0/k3s/kube/" + version.Program + ".yaml"
	GlobalConfig       = "/mnt/user/0/emulated/0/k3s/etc/rancher/" + version.Program + "/" + version.Program + ".yaml"
)

func Resolve(dataDir string) (string, error) {
	return LocalHome(dataDir, false)
}

func LocalHome(dataDir string, forceLocal bool) (string, error) {
	if dataDir == "" {
		if os.Getuid() == 0 && !forceLocal {
			dataDir = DefaultDataDir
		} else {
			dataDir = DefaultHomeDataDir
		}
	}

	dataDir, err := resolvehome.Resolve(dataDir)
	if err != nil {
		return "", errors.Wrapf(err, "resolving %s", dataDir)
	}

	return filepath.Abs(dataDir)
}
