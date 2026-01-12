from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    DateTime,
    ForeignKey,
    Enum
)
from .database import Base
import enum


# =======================
# ENUMS
# =======================

class CategoryEnum(enum.Enum):
    Burger = "Burger"
    Italien = "Italien"
    Pate = "Pate"


# =======================
# USER & FOLLOW
# =======================

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String)
    email = Column(String)
    password = Column(String)
    created_at = Column(DateTime)


class Follow(Base):
    __tablename__ = "follow"

    following_user_id = Column(
        Integer, ForeignKey("user.id"), primary_key=True
    )
    followed_user_id = Column(
        Integer, ForeignKey("user.id"), primary_key=True
    )
    created_at = Column(DateTime)


# =======================
# POSTS
# =======================

class Post(Base):
    __tablename__ = "post"

    id = Column(Integer, primary_key=True)
    description = Column(Text)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime)


class ForumPost(Base):
    __tablename__ = "forum_post"

    id = Column(Integer, primary_key=True)
    title = Column(Text)
    description = Column(Text)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime)


class Mini(Base):
    __tablename__ = "mini"

    id = Column(Integer, primary_key=True)
    description = Column(Text)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime)


# =======================
# PRIVATE MESSAGES
# =======================

class PrivateMessage(Base):
    __tablename__ = "private_message"

    id = Column(Integer, primary_key=True)
    message = Column(Text, nullable=False)
    sender_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    receiver_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime)


# =======================
# RECIPES
# =======================

class Recipe(Base):
    __tablename__ = "recipe"

    id = Column(Integer, primary_key=True)
    description = Column(Text)
    difficulty = Column(Integer)
    image_link = Column(String)
    video_link = Column(String)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime)


# =======================
# CATEGORY TABLES
# =======================

class RecipeCategory(Base):
    __tablename__ = "recipe_category"

    id = Column(Integer, primary_key=True)
    category = Column(Enum(CategoryEnum))
    recipe_id = Column(Integer, ForeignKey("recipe.id"))


class ForumPostCategory(Base):
    __tablename__ = "forum_post_category"

    id = Column(Integer, primary_key=True)
    category = Column(Enum(CategoryEnum))
    forum_post_id = Column(Integer, ForeignKey("forum_post.id"))


class MiniCategory(Base):
    __tablename__ = "mini_category"

    id = Column(Integer, primary_key=True)
    category = Column(Enum(CategoryEnum))
    mini_id = Column(Integer, ForeignKey("mini.id"))


class PostCategory(Base):
    __tablename__ = "post_category"

    id = Column(Integer, primary_key=True)
    category = Column(Enum(CategoryEnum))
    post_id = Column(Integer, ForeignKey("post.id"))


# =======================
# COMMENTS
# =======================

class RecipeComment(Base):
    __tablename__ = "recipe_comment"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"))
    recipe_id = Column(Integer, ForeignKey("recipe.id"))
    created_at = Column(DateTime)


class MiniComment(Base):
    __tablename__ = "mini_comment"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"))
    mini_id = Column(Integer, ForeignKey("mini.id"))
    created_at = Column(DateTime)


class PostComment(Base):
    __tablename__ = "post_comment"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"))
    post_id = Column(Integer, ForeignKey("post.id"))
    created_at = Column(DateTime)


# =======================
# LIKES
# =======================

class RecipeLike(Base):
    __tablename__ = "recipe_like"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("user.id"))
    recipe_id = Column(Integer, ForeignKey("recipe.id"))


class MiniLike(Base):
    __tablename__ = "mini_like"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("user.id"))
    mini_id = Column(Integer, ForeignKey("mini.id"))


class PostLike(Base):
    __tablename__ = "post_like"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("user.id"))
    post_id = Column(Integer, ForeignKey("post.id"))


# =======================
# FORUM RESPONSES
# =======================

class ForumPostResponse(Base):
    __tablename__ = "forum_post_response"

    id = Column(Integer, primary_key=True)
    content = Column(String)
    forum_post_id = Column(Integer, ForeignKey("forum_post.id"))
    user_id = Column(Integer, ForeignKey("user.id"))
    created_at = Column(DateTime)


class ForumPostResponseUpvote(Base):
    __tablename__ = "forum_post_response_upvote"

    id = Column(Integer, primary_key=True)
    forum_post_response_id = Column(
        Integer, ForeignKey("forum_post_response.id")
    )
    user_id = Column(Integer, ForeignKey("user.id"))


# =======================
# RECIPE DETAILS
# =======================

class Ingredient(Base):
    __tablename__ = "ingredient"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    quantity = Column(Integer)
    recipe_id = Column(Integer, ForeignKey("recipe.id"))


class Stage(Base):
    __tablename__ = "stage"

    id = Column(Integer, primary_key=True)
    number = Column(Integer)
    content = Column(String)
    recipe_id = Column(Integer, ForeignKey("recipe.id"))
