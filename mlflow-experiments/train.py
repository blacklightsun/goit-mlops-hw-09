import os
import time
from dotenv import load_dotenv

from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, log_loss

import mlflow
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

load_dotenv()

# Параметри експерименту
EPOCHS = 50
EXPERIMENT_NAME = "Iris Classification"

# URI трекінгу
mlflow.set_tracking_uri(os.environ["MLFLOW_TRACKING_URI"])

# Отримуємо експеримент за назвою
experiment = mlflow.get_experiment_by_name(EXPERIMENT_NAME)
if experiment is None:
    experiment_id = mlflow.create_experiment(EXPERIMENT_NAME)
    print(f"✅ Створено експеримент '{EXPERIMENT_NAME}' (ID={experiment_id})")
else:
    experiment_id = experiment.experiment_id
    print(
        f"ℹ️ Використовується існуючий експеримент '{EXPERIMENT_NAME}' (ID={experiment_id})"
    )

# URL Pushgateway
PUSHGATEWAY_URL = os.environ["PUSHGATEWAY_URL"]
JOB_NAME = os.environ["JOB_NAME"]

# Prometheus metrics
registry = CollectorRegistry()
accuracy_gauge = Gauge(
    "mlflow_model_accuracy",
    "Model accuracy",
    ["experiment", "run_id"],
    registry=registry,
)
loss_gauge = Gauge(
    "mlflow_model_loss",
    "Model loss",
    ["experiment", "run_id"],
    registry=registry,
)
duration_gauge = Gauge(
    "mlflow_training_duration_seconds",
    "Training duration",
    ["experiment", "run_id"],
    registry=registry,
)

# Тренування моделі
start_time = time.time()

X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)

model = LogisticRegression(max_iter=EPOCHS)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)

acc = accuracy_score(y_test, y_pred)
loss = log_loss(y_test, y_proba)

end_time = time.time()
duration = end_time - start_time

print("✅ Експеримент завершено. Перевірте результати в MLflow UI.")

# Логування в MLflow
with mlflow.start_run(experiment_id=experiment_id) as run:

    mlflow.set_tag("experiment_name", EXPERIMENT_NAME)
    mlflow.log_param("epochs", EPOCHS)

    # Логування в MLFlow
    mlflow.log_metric("accuracy", acc)
    mlflow.log_metric("loss", loss)
    mlflow.log_metric("training_time", duration)
    input_example = X_train[:5]
    mlflow.sklearn.log_model(
        model, name="LogisticRegression", input_example=input_example
    )

# Відправка до Pushgateway
accuracy_gauge.labels(experiment=EXPERIMENT_NAME, run_id=run.info.run_id).set(acc)
loss_gauge.labels(experiment=EXPERIMENT_NAME, run_id=run.info.run_id).set(loss)
duration_gauge.labels(experiment=EXPERIMENT_NAME, run_id=run.info.run_id).set(duration)
push_to_gateway(PUSHGATEWAY_URL, job=JOB_NAME, registry=registry)
