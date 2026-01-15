from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    Text,
    DateTime,
    ForeignKey,
    Enum,
    func,
)
from .database import Base
import enum


class CategoryEnum(enum.Enum):
    Burger = "Burger"
    Italien = "Italien"
    Pate = "Pate"
    
class UnitEnum(enum.Enum):
    kg = "kg"
    g = "g"
    mL = "mL"
    L = "L"
    u = "u"

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True)
    email = Column(String, unique=True)
    password = Column(String)
    created_at = Column(DateTime, server_default=func.now())


class Follow(Base):
    __tablename__ = "follow"

    following_user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)
    followed_user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)
    created_at = Column(DateTime, server_default=func.now())


class Post(Base):
    __tablename__ = "post"

    id = Column(Integer, primary_key=True)
    description = Column(Text)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class ForumPost(Base):
    __tablename__ = "forum_post"

    id = Column(Integer, primary_key=True)
    title = Column(Text, nullable=False)
    description = Column(Text, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class Mini(Base):
    __tablename__ = "mini"

    id = Column(Integer, primary_key=True)
    description = Column(Text)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class PrivateMessage(Base):
    __tablename__ = "private_message"

    id = Column(Integer, primary_key=True)
    message = Column(Text, nullable=False)
    sender_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    receiver_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class Recipe(Base):
    __tablename__ = "recipe"

    id = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
    tips = Column(Text)
    difficulty = Column(Integer)
    image_link = Column(String, nullable=False)
    video_link = Column(String)
    preparation_time = Column(Integer)
    baking_time = Column(Integer)
    person = Column(Integer)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class RecipeCategory(Base):
    __tablename__ = "recipe_category"

    category = Column(Enum(CategoryEnum), primary_key=True)
    recipe_id = Column(Integer, ForeignKey("recipe.id"), primary_key=True)


class ForumPostCategory(Base):
    __tablename__ = "forum_post_category"

    category = Column(Enum(CategoryEnum), primary_key=True)
    forum_post_id = Column(Integer, ForeignKey("forum_post.id"), primary_key=True)


class MiniCategory(Base):
    __tablename__ = "mini_category"

    category = Column(Enum(CategoryEnum), primary_key=True)
    mini_id = Column(Integer, ForeignKey("mini.id"), primary_key=True)


class PostCategory(Base):
    __tablename__ = "post_category"

    category = Column(Enum(CategoryEnum), primary_key=True)
    post_id = Column(Integer, ForeignKey("post.id"), primary_key=True)


class RecipeComment(Base):
    __tablename__ = "recipe_comment"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    recipe_id = Column(Integer, ForeignKey("recipe.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class MiniComment(Base):
    __tablename__ = "mini_comment"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    mini_id = Column(Integer, ForeignKey("mini.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class PostComment(Base):
    __tablename__ = "post_comment"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    post_id = Column(Integer, ForeignKey("post.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class RecipeLike(Base):
    __tablename__ = "recipe_like"

    user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)
    recipe_id = Column(Integer, ForeignKey("recipe.id"), primary_key=True)


class MiniLike(Base):
    __tablename__ = "mini_like"

    user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)
    mini_id = Column(Integer, ForeignKey("mini.id"), primary_key=True)


class PostLike(Base):
    __tablename__ = "post_like"

    user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)
    post_id = Column(Integer, ForeignKey("post.id"), primary_key=True)


class ForumPostResponse(Base):
    __tablename__ = "forum_post_response"

    id = Column(Integer, primary_key=True)
    content = Column(String, nullable=False)
    forum_post_id = Column(Integer, ForeignKey("forum_post.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class ForumPostResponseUpvote(Base):
    __tablename__ = "forum_post_response_upvote"

    forum_post_response_id = Column(
        Integer, ForeignKey("forum_post_response.id"), primary_key=True
    )
    user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)


class RecipeIngredient(Base):
    __tablename__ = "recipe_ingredient"

    id = Column(Integer, primary_key=True)
    ingredient = Column(String, nullable=False)
    unit = Column(Enum(UnitEnum), nullable=False)
    quantity = Column(Float)
    recipe_id = Column(Integer, ForeignKey("recipe.id"))


class Step(Base):
    __tablename__ = "step"

    id = Column(Integer, primary_key=True)
    number = Column(Integer)
    content = Column(String)
    recipe_id = Column(Integer, ForeignKey("recipe.id"))