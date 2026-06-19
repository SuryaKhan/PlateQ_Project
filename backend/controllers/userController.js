const prisma = require('../db');
const bcrypt = require('bcrypt');

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
          include: { 
            recipe: {
              include: { author: true }
            }
          }
        },
        comments: {    // Komentarku
          include: { recipe: true }
        },
        _count: {
          select: { followers: true, following: true }
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
      myComments: userProfile.comments,
      followers: userProfile._count.followers,
      following: userProfile._count.following
    };

    res.json(responseData);
  } catch (error) {
    console.error("❌ ERROR GET PROFILE:", error);
    res.status(500).json({ error: "Gagal mengambil data profil." });
  }
};

// 2.5 GET PUBLIC PROFILE
exports.getPublicProfile = async (req, res) => {
  try {
    const { id } = req.params;
    const userProfile = await prisma.user.findUnique({
      where: { id: parseInt(id) },
      include: {
        recipes: true,
        _count: {
          select: { followers: true, following: true }
        }
      }
    });

    if (!userProfile) return res.status(404).json({ error: "User not found" });

    res.json({
      id: userProfile.id,
      username: userProfile.username,
      name: userProfile.name,
      bio: userProfile.bio,
      profileImage: userProfile.profileImage,
      role: userProfile.role,
      recipes: userProfile.recipes,
      followersCount: userProfile._count.followers,
      followingCount: userProfile._count.following
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getPublicProfileByUsername = async (req, res) => {
  try {
    const username = req.params.username;
    const userProfile = await prisma.user.findUnique({
      where: { username },
      include: {
        recipes: true,
        _count: {
          select: { followers: true, following: true }
        }
      }
    });

    if (!userProfile) return res.status(404).json({ error: "User not found" });

    res.json({
      id: userProfile.id,
      username: userProfile.username,
      name: userProfile.name,
      bio: userProfile.bio,
      profileImage: userProfile.profileImage,
      role: userProfile.role,
      recipes: userProfile.recipes,
      followersCount: userProfile._count.followers,
      followingCount: userProfile._count.following
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.uploadProfileImage = async (req, res) => {
  try {
    const userId = req.user.userId;
    if (!req.file) {
      return res.status(400).json({ error: "Tidak ada gambar yang diupload" });
    }
    const profileImage = req.file.filename;

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { profileImage },
    });

    res.json({ message: "Foto profil berhasil diperbarui!", profileImage: updatedUser.profileImage });
  } catch (error) {
    console.error("❌ ERROR UPLOAD PROFILE IMAGE:", error);
    res.status(500).json({ error: "Gagal mengupload foto." });
  }
};

// 4. CHANGE PASSWORD
exports.changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: "Password lama dan baru wajib diisi." });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({ error: "Password baru minimal 8 karakter." });
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return res.status(404).json({ error: "User tidak ditemukan." });
    }

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Password lama salah." });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword }
    });

    res.json({ message: "Password berhasil diubah!" });
  } catch (error) {
    console.error("❌ ERROR CHANGE PASSWORD:", error);
    res.status(500).json({ error: "Terjadi kesalahan saat mengubah password." });
  }
};

// 5. SEARCH USERS
exports.searchUsers = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.json([]);
    }

    let currentUserId = null;
    const authHeader = req.headers['authorization'];
    if (authHeader) {
      const token = authHeader.split(' ')[1];
      if (token && token !== "null" && token !== "undefined") {
        try {
          const jwt = require('jsonwebtoken');
          const decoded = jwt.verify(token, process.env.JWT_SECRET || 'rahasia');
          currentUserId = decoded.userId;
        } catch (e) {
          // token tidak valid atau expired, abaikan saja
        }
      }
    }

    const users = await prisma.user.findMany({
      where: {
        OR: [
          { username: { contains: q } },
          { name: { contains: q } }
        ]
      },
      select: {
        id: true,
        username: true,
        name: true,
        profileImage: true,
        role: true,
        _count: {
          select: { followers: true }
        },
        followers: currentUserId ? {
          where: { followerId: currentUserId },
          select: { id: true }
        } : false
      },
      take: 20
    });

    const formattedUsers = users.map(user => {
      const { followers, ...rest } = user;
      return {
        ...rest,
        isFollowing: followers ? followers.length > 0 : false
      };
    });

    res.json(formattedUsers);
  } catch (error) {
    console.error("❌ ERROR SEARCH USERS:", error);
    res.status(500).json({ error: "Gagal mencari pengguna." });
  }
};
