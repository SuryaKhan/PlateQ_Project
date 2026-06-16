const request = require('supertest');
const app = require('../index');
const prisma = require('../db');
const jwt = require('jsonwebtoken');

jest.mock('../db', () => require('jest-mock-extended').mockDeep());

beforeEach(() => {
  require('jest-mock-extended').mockReset(prisma);
});

const generateToken = (userId, username) => {
  return jwt.sign({ userId, username }, process.env.JWT_SECRET || 'rahasia_plateq_2026', { expiresIn: '1h' });
};

describe('Social API', () => {
  describe('POST /api/social/follow/:id', () => {
    it('should follow a user successfully', async () => {
      const token = generateToken(1, 'follower_user');
      prisma.follow.findUnique.mockResolvedValue(null);
      
      prisma.follow.create.mockResolvedValue({ followerId: 1, followingId: 2 });
      prisma.notification.create.mockResolvedValue({ id: 1 });

      const res = await request(app)
        .post('/api/social/follow/2')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toContain('Followed successfully');
      expect(prisma.follow.create).toHaveBeenCalled();
    });

    it('should unfollow if already following', async () => {
      const token = generateToken(1, 'follower_user');
      prisma.follow.findUnique.mockResolvedValue({ id: 5, followerId: 1, followingId: 2 });
      
      prisma.follow.delete.mockResolvedValue({ id: 5 });

      const res = await request(app)
        .post('/api/social/follow/2')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toContain('Unfollowed successfully');
      expect(prisma.follow.delete).toHaveBeenCalled();
    });
  });

  describe('PUT /api/social/notifications/read', () => {
    it('should mark all notifications as read', async () => {
      const token = generateToken(1, 'user');
      prisma.notification.updateMany.mockResolvedValue({ count: 5 });

      const res = await request(app)
        .put('/api/social/notifications/read')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toEqual(200);
    });
  });
});
