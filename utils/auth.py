from flask import session, redirect, url_for, flash
from functools import wraps

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# New
# def role_required(roles):
#     def decorator(f):
#         @wraps(f)
#         def decorated_function(*args, **kwargs):
#             if 'role' not in session or session['role'] not in roles:
#                 flash('No tienes permisos para acceder a esta página', 'error')
#                 return redirect(url_for('dashboard.dashboard'))
#             return f(*args, **kwargs)
#         return decorated_function
#     return decorator

def role_required(roles):
    def decorator(f):

        @wraps(f)
        def decorated_function(*args, **kwargs):

            if 'user_roles' not in session:
                return redirect('/login')

            user_roles = session['user_roles']

            if not any(role in user_roles for role in roles):
                flash(
                    'No tiene permisos para acceder a esta sección',
                    'error'
                )

                return redirect('/login')

            return f(*args, **kwargs)

        return decorated_function

    return decorator