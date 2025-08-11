from flask_login import UserMixin
from app.db import get_user_by_id

class User(UserMixin):
    def __init__(self, id, username, email, password_hash):
        self.id = id
        self.username = username
        self.email = email
        self.password_hash = password_hash

    @staticmethod
    def get(user_id):
        user_data = get_user_by_id(user_id)
        if user_data:
            return User(
                id=user_data['id'],
                username=user_data['username'],
                email=user_data['email'],
                password_hash=user_data['password_hash']
            )
        return None
