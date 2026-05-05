import sys
sys.path.insert(0, 'back')
from common.database import SessionLocal
from common import models

with SessionLocal() as db:
    notifications = db.query(models.Notification).all()
    for n in notifications:
        print(f"id={n.id}, user_id={n.user_id}, sender_id={n.sender_id}, type={n.type}, is_read={n.is_read}")
