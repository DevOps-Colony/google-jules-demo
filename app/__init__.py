from flask import Flask
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')

# Initialize CSRF protection
csrf = CSRFProtect(app)

# Make csrf_token available in all templates
@app.context_processor
def inject_csrf_token():
    from flask_wtf.csrf import generate_csrf
    return dict(csrf_token=generate_csrf)

login = LoginManager(app)
login.login_view = 'login'

from app import routes, models

@login.user_loader
def load_user(user_id):
    """Load user from the database."""
    # This function should be adapted to your user loading logic,
    # for example, fetching a user from a database.
    # Here, we'll need to implement the logic to fetch a user from DynamoDB.
    # For now, this is a placeholder.
    # You will need to replace this with your actual user loading logic.
    # Example: return User.query.get(int(user_id))
    # In our case, we will use a function from our db.py to get the user.
    return models.User.get(user_id)
