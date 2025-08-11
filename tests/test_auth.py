import unittest
from app import app, db
from app.models import User

class AuthTestCase(unittest.TestCase):
    def setUp(self):
        app.config['TESTING'] = True
        app.config['WTF_CSRF_ENABLED'] = False
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite://'
        self.app = app.test_client()
        self.app_context = app.app_context()
        self.app_context.push()
        db.create_all()

    def tearDown(self):
        db.session.remove()
        db.drop_all()
        self.app_context.pop()

    def test_password_hashing(self):
        u = User(username='susan')
        u.set_password('cat')
        self.assertFalse(u.check_password('dog'))
        self.assertTrue(u.check_password('cat'))

    def test_register(self):
        response = self.app.post('/register', data={
            'username': 'john',
            'email': 'john@example.com',
            'password': 'password',
            'password2': 'password'
        }, follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        user = User.query.filter_by(username='john').first()
        self.assertIsNotNone(user)
        self.assertEqual(user.email, 'john@example.com')

    def test_login_logout(self):
        # register a user
        u = User(username='susan', email='susan@example.com')
        u.set_password('cat')
        db.session.add(u)
        db.session.commit()

        # login
        response = self.app.post('/login', data={
            'username': 'susan',
            'password': 'cat'
        }, follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Welcome to the Home Page!', response.data)

        # logout
        response = self.app.get('/logout', follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Sign In', response.data)

if __name__ == '__main__':
    unittest.main()
