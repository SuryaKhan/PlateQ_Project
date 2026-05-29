const prisma = require('../db');

// 1. UPDATE PROFILE
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.userId; 
    const { name, bio, preferences, username, email, phone, profileImage } = req.body;

    // Optional: check if username or email is already taken by someone else
    if (username || email) {
      const existingUser = await prisma.user.findFirst({
        where: {
          OR: [
            { username: username || undefined },
            { email: email || undefined }
          ],
          NOT: { id: userId }
        }
      });
      if (existingUser) {
        return res.status(400).json({ error: "Username atau Email sudah dipakai orang lain!" });
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        name,
        bio,
        preferences,
        username,
        email,
        phone,
        profileImage
      },
    });

    res.json({ 
      message: "Profil berhasil diperbarui!", 
      user: {
        id: updatedUser.id,
        username: updatedUser.username,
        name: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        bio: updatedUser.bio,
        profileImage: updatedUser.profileImage
      }
    });
  } catch (error) {
    console.error("❌ ERROR UPDATE PROFILE:", error);
    res.status(500).json({ error: "Gagal memperbarui profil." });
  }
};

// 2. GET PROFILE DETAIL
exports.getProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    const userProfile = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        recipes: true, // Resepku
        likes: {       // Favoritku (Bookmark)
          include: { recipe: true }
        },
        comments: {    // Komentarku
          include: { recipe: true }
        }
      }
    });

    if (!userProfile) {
      return res.status(404).json({ error: "User tidak ditemukan!" });
    }

    // Format response agar mudah dipakai di Flutter
    const responseData = {
      id: userProfile.id,
      username: userProfile.username,
      name: userProfile.name,
      email: userProfile.email,
      phone: userProfile.phone,
      bio: userProfile.bio,
      profileImage: userProfile.profileImage,
      role: userProfile.role,
      myRecipes: userProfile.recipes,
      favoriteRecipes: userProfile.likes.map(like => like.recipe),
      myComments: userProfile.comments
    };

    res.json(responseData);
  } catch (error) {
    console.error("❌ ERROR GET PROFILE:", error);
    res.status(500).json({ error: "Gagal mengambil data profil." });
  }
};