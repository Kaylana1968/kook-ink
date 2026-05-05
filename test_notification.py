#!/usr/bin/env python3
import sys
sys.path.insert(0, 'back')

from common.database import SessionLocal
from common import models

# Créer une notification de test
db = SessionLocal()

# Créer une notification fictive (comme si quelqu'un aimait une recette)
notif = models.Notification(
    user_id=1,  # Remplacez par votre user_id
    sender_id=2,  # Remplacez par un autre user_id
    type="like_recipe",
    target_id=1,
    is_read="false"
)

db.add(notif)
db.commit()

print("✅ Notification de test créée!")
print(f"ID: {notif.id}")
print("Lancez l'app et allez sur l'icône 🔔 pour voir la notification")

db.close()
