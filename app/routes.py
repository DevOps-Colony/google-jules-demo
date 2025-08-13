from flask import render_template, flash, redirect, url_for, request
from app import app
from app.models import User
from app.db import get_user_by_username, create_user, check_password
from flask_login import login_user, logout_user, current_user, login_required
from urllib.parse import urlparse

@app.route('/')
@app.route('/index')
@login_required
def index():
    return render_template('home.html', title='Home')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    if request.method == 'POST':
        user_data = get_user_by_username(request.form['username'])
        if user_data is None or not check_password(user_data['password_hash'], request.form['password']):
            flash('Invalid username or password')
            return redirect(url_for('login'))
        user = User(
            id=user_data['id'],
            username=user_data['username'],
            email=user_data['email'],
            password_hash=user_data['password_hash']
        )
        login_user(user)
        next_page = request.args.get('next')
        if not next_page or urlparse(next_page).netloc != '':
            next_page = url_for('index')
        return redirect(next_page)
    return render_template('login.html', title='Sign In')

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('index'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    if request.method == 'POST':
        if get_user_by_username(request.form['username']):
            flash('Please use a different username.')
            return redirect(url_for('register'))
        create_user(
            username=request.form['username'],
            email=request.form['email'],
            password=request.form['password']
        )
        flash('Congratulations, you are now a registered user!')
        return redirect(url_for('login'))
    return render_template('register.html', title='Register')
