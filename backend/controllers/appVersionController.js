const prisma = require('../db');

// 1. Dapatkan Versi Aplikasi Terbaru
exports.getLatestVersion = async (req, res) => {
  try {
    const latestVersion = await prisma.appVersion.findFirst({
      orderBy: { buildNumber: 'desc' }
    });

    if (!latestVersion) {
      return res.status(404).json({ error: "Belum ada versi yang diunggah." });
    }

    res.json(latestVersion);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. Publish Versi Baru (Hanya Super Admin)
exports.publishNewVersion = async (req, res) => {
  try {
    // Pastikan hanya SUPERADMIN yang bisa publish update
    if (req.user.role !== 'SUPERADMIN') {
      return res.status(403).json({ error: "Hanya Super Admin yang bisa mempublish update aplikasi." });
    }

    const { versionString, buildNumber, releaseNotes, apkUrl, isMandatory } = req.body;

    if (!versionString || !buildNumber || !apkUrl) {
      return res.status(400).json({ error: "versionString, buildNumber, dan apkUrl wajib diisi!" });
    }

    const newVersion = await prisma.appVersion.create({
      data: {
        versionString,
        buildNumber: parseInt(buildNumber),
        releaseNotes,
        apkUrl,
        isMandatory: isMandatory || false,
      }
    });

    res.status(201).json({ message: "Berhasil mempublish pembaruan aplikasi!", data: newVersion });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
