# Development Manual

## BACKEND

First of all, you need to have Python installed on your computer.

### Installing dependencies

Go to the `back/` folder. Get your terminal in a .venv and run this command :

```bash
pip install -r requirements.txt
```

### Setup

You also need to add a `.env` file at the root of the `back/` folder.

```ini
DATABASE_URL="postgresql+psycopg2://USERNAME:PASSWORD@HOST:PORT/kookink"
SECRET_KEY="YOUR_SECRET_KEY"
CLOUDINARY_URL="cloudinary://the_cloudinary_url"
```

### Running dev mode

Go to the `back/` folder and run :

```bash
fastapi dev main.py
```

### File architecture

```
back/
├── common/
├── controller/
├── test/
├── main.py
└── requirements.txt
```

All the libraries used are referenced in `requirements.txt`. Feel free to check the file.

The `common/` folder is used for functions, methods or utilities used across all the files like the database models, the cloudinary connection or the auth functions.

The `controller/` folder is where you create your API routes. We create a file for each feature like `recipe.py`, `post.py` or `forum.py`. Create a router in the files and then import it and add it to the API in the `main.py` file.

The folder `test/` is used for doing unit test. We use **pytest** for testing.

## FRONTEND

You need to have flutter installed on your computer for all the following.

### Install dependencies

Go to the `front/` folder and run this command :

```bash
flutter pub get
```

### Setup

You also have to add a `.env` file at the root of the `front/` folder.

```ini
BASE_URL="http://your_backend_url"
CLOUDINARY_URL="cloudinary://the_cloudinary_url"
```

### Run dev mode

Go to the `front/` folder and run :

```bash
flutter run
```

### File architecture

```
front/
├── android/
├── assets/
├── ios/
├── lib/
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── pubspec.lock
└── pubspec.yaml
```

Most of the files in the project are auto-generated. The only useful ones are the `lib/` and `test/` folders and the `pubspec.yaml`.

The `pubspec.yaml` file is where we add libraries to the project. Check it so you know what we use.

The core of the app should be written in the `lib/` folder. In it, create a folder for each page like `profile/`, `home/`. We use the library GoRouter for routes

The tests are done in `test/` folder. We use the default flutter_test library for unit tests.

