const request = require('supertest');
const app = require('../index');
const prisma = require('../db');
const { mockDeep, mockReset } = require('jest-mock-extended');

jest.mock('../db', () => require('jest-mock-extended').mockDeep());

beforeEach(() => {
  mockReset(prisma);
});

describe('Auth API', () => {
  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      // Mock db response
      prisma.user.findUnique.mockResolvedValue(null);
      prisma.user.create.mockResolvedValue({
        id: 1,
        username: 'newuser',
        email: 'newuser@example.com',
        role: 'USER'
      });

      const res = await request(app)
        .post('/api/auth/register')
        .send({
          username: 'newuser',
          email: 'newuser@example.com',
          password: 'password123'
        });

      expect(res.statusCode).toEqual(201);
      expect(res.body.message).toContain('berhasil dibuat');
      expect(prisma.user.create).toHaveBeenCalledTimes(1);
    });

    it('should fail if email already exists', async () => {
      const error = new Error('Unique constraint failed');
      error.code = 'P2002';
      prisma.user.create.mockRejectedValue(error);

      const res = await request(app)
        .post('/api/auth/register')
        .send({
          username: 'test',
          email: 'test@example.com',
          password: 'password123'
        });

      expect(res.statusCode).toEqual(400);
      expect(res.body.error).toContain('sudah dipakai');
    });
  });

  describe('POST /api/auth/login', () => {
    it('should return 404 if user not found', async () => {
      prisma.user.findFirst.mockResolvedValue(null);

      const res = await request(app)
        .post('/api/auth/login')
        .send({
          username: 'notfound@example.com',
          password: 'wrongpassword'
        });

      expect(res.statusCode).toEqual(404);
      expect(res.body.error).toContain('nggak ketemu');
    });
  });
});
