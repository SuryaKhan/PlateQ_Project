const request = require('supertest');
const app = require('../index');
const prisma = require('../db');
const jwt = require('jsonwebtoken');

jest.mock('../db', () => require('jest-mock-extended').mockDeep());

beforeEach(() => {
  require('jest-mock-extended').mockReset(prisma);
});

// Helper to generate fake token
const generateToken = (userId, username) => {
  return jwt.sign({ userId, username }, process.env.JWT_SECRET || 'rahasia_plateq_2026', { expiresIn: '1h' });
};

describe('Admin API', () => {
  describe('GET /api/admin/stats', () => {
    it('should return dashboard stats for admin', async () => {
      // Mock auth check
      const token = generateToken(1, 'admin_user');
      prisma.user.findUnique.mockResolvedValue({ id: 1, role: 'ADMIN' });
      
      // Mock stats
      prisma.user.count.mockResolvedValue(10);
      prisma.recipe.count.mockResolvedValue(25);

      const res = await request(app)
        .get('/api/admin/stats')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.totalUsers).toEqual(10);
      expect(res.body.totalRecipes).toEqual(25);
    });

    it('should return 403 if user is not admin', async () => {
      const token = generateToken(2, 'normal_user');
      prisma.user.findUnique.mockResolvedValue({ id: 2, role: 'USER' });

      const res = await request(app)
        .get('/api/admin/stats')
        .set('Authorization', `Bearer ${token}`);

      expect(res.statusCode).toEqual(403);
      expect(res.body.error).toContain('Akses ditolak');
    });
  });

  describe('POST /api/admin/announcements', () => {
    it('should create announcement and notify users', async () => {
      const token = generateToken(1, 'admin_user');
      prisma.user.findUnique.mockResolvedValue({ id: 1, role: 'ADMIN' });
      
      prisma.announcement.create.mockResolvedValue({ id: 1, title: 'Update', content: 'V2', category: 'UPDATE_APK' });
      prisma.user.findMany.mockResolvedValue([{ id: 2 }, { id: 3 }]);
      prisma.notification.createMany.mockResolvedValue({ count: 2 });

      const res = await request(app)
        .post('/api/admin/announcements')
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'Update', content: 'V2', category: 'UPDATE_APK' });

      expect(res.statusCode).toEqual(201);
      expect(res.body.message).toContain('berhasil dibuat');
      expect(prisma.notification.createMany).toHaveBeenCalled();
    });
  });
});
