import unittest
from unittest.mock import patch
from app import app
from app.models import User
from werkzeug.security import generate_password_hash
from app.db import check_password

class AuthTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        self.app_context = app.app_context()
        self.app_context.push()

    def tearDown(self):
        self.app_context.pop()

    def test_password_hashing(self):
        password_hash = generate_password_hash('cat')
        self.assertFalse(check_password(password_hash, 'dog'))
        self.assertTrue(check_password(password_hash, 'cat'))

    @patch('app.routes.get_user_by_username')
    @patch('app.routes.create_user')
    def test_register(self, mock_create_user, mock_get_user_by_username):
        mock_get_user_by_username.return_value = None
        mock_create_user.return_value = True

        response = self.app.post('/register', data={
            'username': 'john',
            'email': 'john@example.com',
            'password': 'password'
        }, follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Congratulations, you are now a registered user!', response.data)
        mock_create_user.assert_called_once_with(username='john', email='john@example.com', password='password')

    @patch('app.models.User.get')
    @patch('app.routes.get_user_by_username')
    def test_login_logout(self, mock_get_user_by_username, mock_user_get):
        password_hash = generate_password_hash('cat')
        user_data = {
            'id': '123',
            'username': 'susan',
            'email': 'susan@example.com',
            'password_hash': password_hash
        }
        mock_get_user_by_username.return_value = user_data

        # This mocks the user_loader
        mock_user_get.return_value = User(
            id=user_data['id'],
            username=user_data['username'],
            email=user_data['email'],
            password_hash=user_data['password_hash']
        )

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
