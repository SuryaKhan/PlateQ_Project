const prisma = require('../db');

// 1. FOLLOW & UNFOLLOW
exports.toggleFollow = async (req, res) => {
  try {
    const followerId = req.user.userId;
    const followingId = parseInt(req.params.id);

    if (followerId === followingId) {
      return res.status(400).json({ error: "Cannot follow yourself." });
    }

    const existingFollow = await prisma.follow.findUnique({
      where: { followerId_followingId: { followerId, followingId } }
    });

    if (existingFollow) {
      // Unfollow
      await prisma.follow.delete({ where: { id: existingFollow.id } });
      res.json({ message: "Unfollowed successfully." });
    } else {
      // Follow
      await prisma.follow.create({ data: { followerId, followingId } });
      // Create notification
      await prisma.notification.create({
        data: {
          userId: followingId,
          type: "FOLLOW",
          message: `${req.user.username} mulai mengikuti Anda.`
        }
      });
      res.json({ message: "Followed successfully." });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. COOKSNAPS
exports.uploadCooksnap = async (req, res) => {
  try {
    const recipeId = parseInt(req.params.recipeId);
    const userId = req.user.userId;
    const comment = req.body.comment;
    
    if (!req.file) {
      return res.status(400).json({ error: "Image is required for Cooksnap" });
    }

    const cooksnap = await prisma.cooksnap.create({
      data: {
        userId,
        recipeId,
        image: req.file.filename,
        comment
      }
    });

    // Create Notification for the recipe author
    const recipe = await prisma.recipe.findUnique({ where: { id: recipeId } });
    if (recipe && recipe.authorId !== userId) {
      await prisma.notification.create({
        data: {
          userId: recipe.authorId,
          type: "COOKSNAP",
          message: `${req.user.username} mencoba resep Anda: ${recipe.title}!`
        }
      });
    }

    res.status(201).json(cooksnap);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 3. COLLECTIONS (FOLDERS)
exports.createCollection = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name } = req.body;
    const collection = await prisma.collection.create({
      data: { userId, name }
    });
    res.status(201).json(collection);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getCollections = async (req, res) => {
  try {
    const collections = await prisma.collection.findMany({
      where: { userId: req.user.userId },
      include: { items: { include: { recipe: true } } }
    });
    res.json(collections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.saveRecipeToCollection = async (req, res) => {
  try {
    const collectionId = parseInt(req.params.collectionId);
    const recipeId = parseInt(req.params.recipeId);

    // Verify ownership
    const collection = await prisma.collection.findUnique({ where: { id: collectionId } });
    if (!collection || collection.userId !== req.user.userId) {
      return res.status(403).json({ error: "Not authorized" });
    }

    const item = await prisma.collectionItem.create({
      data: { collectionId, recipeId }
    });
    res.status(201).json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 4. NOTIFICATIONS
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.userId },
      orderBy: { createdAt: 'desc' }
    });
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.markNotificationsAsRead = async (req, res) => {
  try {
    await prisma.notification.updateMany({
      where: { userId: req.user.userId, isRead: false },
      data: { isRead: true }
    });
    res.json({ message: "Notifications marked as read" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 5. FEED (Recipes from following)
exports.getFeed = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { page, limit } = req.query;

    const pageNum = parseInt(page) || 1;
    const takeNum = parseInt(limit) || 10;
    const skipNum = (pageNum - 1) * takeNum;
    
    // Get all userIds this user follows
    const following = await prisma.follow.findMany({
      where: { followerId: userId },
      select: { followingId: true }
    });
    
    const followingIds = following.map(f => f.followingId);
    
    // Get recipes from these authors
    const feed = await prisma.recipe.findMany({
      where: { authorId: { in: followingIds } },
      skip: skipNum,
      take: takeNum,
      include: { author: true, _count: { select: { likes: true, comments: true } } },
      orderBy: { createdAt: 'desc' }
    });
    
    res.json(feed);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
