from flask import Flask
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'a-default-secret-key-for-dev')
csrf = CSRFProtect(app)

login = LoginManager(app)
login.login_view = 'login'

from app import routes, models

@login.user_loader
def load_user(user_id):
    return models.User.get(user_id)
