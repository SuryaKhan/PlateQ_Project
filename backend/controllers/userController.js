const prisma = require('../db');

exports.updateProfile = async (req, res) => {
  try {
    // userId didapat dari token JWT via authMiddleware
    const userId = req.user.userId; 
    const { name, bio, preferences } = req.body;

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        name: name,
        // Jika nanti di prisma sudah ditambah kolom bio/preferences:
        // bio: bio,
        // preferences: preferences
      },
    });

    res.json({ 
      message: "Profil berhasil diperbarui, siap masak!", 
      user: {
        username: updatedUser.username,
        name: updatedUser.name,
        email: updatedUser.email
      }
    });
  } catch (error) {
    console.error("❌ ERROR UPDATE PROFILE:", error);
    res.status(500).json({ error: "Gagal memperbarui profil." });
  }
};