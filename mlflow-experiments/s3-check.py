import boto3
from botocore.exceptions import ClientError, EndpointConnectionError

import os
from dotenv import load_dotenv

load_dotenv()

print(os.environ["MLFLOW_S3_ENDPOINT_URL"])
print(os.environ["AWS_ACCESS_KEY_ID"])
print(os.environ["AWS_SECRET_ACCESS_KEY"])
# print(os.environ["BUCKET_NAME"])


# ❗️ Вкажіть ваші дані тут
# Замініть на адресу, яку ви отримали через NodePort або port-forward
ENDPOINT_URL = os.environ["MLFLOW_S3_ENDPOINT_URL"]
ACCESS_KEY = os.environ["AWS_ACCESS_KEY_ID"]  # Ваш Access Key від MinIO
SECRET_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]  # Ваш Secret Key від MinIO
BUCKET_NAME = "mlflow-artifacts"  # Назва бакета, який перевіряємо

# ACCESS_KEY = "YOUR_ACCESS_KEY"  # Ваш Access Key від MinIO
# SECRET_KEY = "YOUR_SECRET_KEY"  # Ваш Secret Key від MinIO


# Створюємо клієнт для S3, вказуючи всі наші параметри
s3_client = boto3.client(
    "s3",
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
)

# Основна логіка перевірки
try:
    # Метод head_bucket() - це легкий запит, який просто перевіряє
    # існування бакета та доступ до нього, не завантажуючи дані.
    s3_client.head_bucket(Bucket=BUCKET_NAME)

    print(f"✅ Успіх! Бакет '{BUCKET_NAME}' знайдено та доступний.")
    print(f"   Адреса серверу: {ENDPOINT_URL}")

except EndpointConnectionError:
    print(
        f"❌ Помилка підключення! Не вдалося з'єднатися з сервером за адресою: {ENDPOINT_URL}"
    )
    print(
        "   Перевірте, чи правильно вказано IP-адресу, порт та чи запущено port-forward."
    )

except ClientError as e:
    # Якщо бакет не знайдено, boto3 поверне помилку 404
    if e.response["Error"]["Code"] == "404":
        print(f"❌ Помилка: Бакет '{BUCKET_NAME}' не знайдено (404).")
        print("   Перевірте, чи правильно вказана назва бакета.")
    # Якщо немає прав доступу, буде помилка 403
    elif e.response["Error"]["Code"] == "403":
        print(f"❌ Помилка: Доступ до бакета '{BUCKET_NAME}' заборонено (403).")
        print("   Перевірте правильність ваших ACCESS_KEY та SECRET_KEY.")
    else:
        # Інші можливі помилки
        print(f"❌ Виникла невідома помилка: {e}")
