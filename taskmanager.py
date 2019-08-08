import os

from flask import Flask
from flask import render_template
from flask import request
from flask import redirect

from flask_sqlalchemy import SQLAlchemy


def get_env_variable(name):
    try:
        return os.environ[name]
    except KeyError:
        message = "Expected environment variable '{}' not set.".format(name)
        raise Exception(message)

# the values of those depend on your setup
POSTGRES_SERVER = get_env_variable("POSTGRES_SERVER")     # 10.46.140.215
POSTGRES_USER = get_env_variable("POSTGRES_USER")         #
POSTGRES_PASSWORD = get_env_variable("POSTGRES_PASSWORD") # 
POSTGRES_DATABASE = get_env_variable("POSTGRES_DATABASE") # era_pg_db    

DB_URL = 'postgresql+psycopg2://{user}:{pw}@{url}/{db}'.format(
    user=POSTGRES_USER,
    pw=POSTGRES_PASSWORD,
    url=POSTGRES_SERVER,
    db=POSTGRES_DATABASE)

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = DB_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # silence the deprecation warning

db = SQLAlchemy(app)

class Task(db.Model):
    title = db.Column(db.String(80), unique=True, nullable=False, primary_key=True)

    def __repr__(self):
        return "<Title: {}>".format(self.title)


@app.route("/", methods=["GET", "POST"])
def home():
    tasks = None
    if request.form:
        try:
            task = Task(title=request.form.get("title"))
            db.session.add(task)
            db.session.commit()
        except Exception as e:
            print("Failed to add task")
            print(e)
    tasks = Task.query.all()
    return render_template("index.html", tasks=tasks)


@app.route("/update", methods=["POST"])
def update():
    try:
        newtitle = request.form.get("newtitle")
        oldtitle = request.form.get("oldtitle")
        task = Task.query.filter_by(title=oldtitle).first()
        task.title = newtitle
        db.session.commit()
    except Exception as e:
        print("Couldn't update task title")
        print(e)
    return redirect("/")


@app.route("/delete", methods=["POST"])
def delete():
    title = request.form.get("title")
    task = Task.query.filter_by(title=title).first()
    db.session.delete(task)
    db.session.commit()
    return redirect("/")


if __name__ == "__main__":
    db.create_all()
    app.run(host='0.0.0.0', port=8087, debug=True)
