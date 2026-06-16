const request = require('supertest');
const app = require('../index');

describe('User API', () => {
  it('should return 401 if accessing profile without token', async () => {
    const res = await request(app).get('/api/users/profile');
    expect(res.statusCode).toEqual(401);
    expect(res.body).toHaveProperty('error', 'Token nggak ada bro!');
  });
});
