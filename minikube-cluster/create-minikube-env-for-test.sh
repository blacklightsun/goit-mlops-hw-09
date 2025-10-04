#!/usr/bin/env bash
# === Minikube 3-node cluster + addons ===
# Автоматичне налаштування кластера та встановлення корисних компонентів


# --- Змінні користувача ---
NUM_NODES=2   # <- сюди можна поставити будь-яку кількість нод

# --- Налаштування хоста ---
TOTAL_CPUS=$(nproc)                     
TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}') # MB
TOTAL_DISK=$(df --output=avail / | tail -n 1) # KB

# --- Розрахунок ресурсів ---
CPUS_PER_NODE=$(( (TOTAL_CPUS * 2 / 3) / NUM_NODES ))
MEM_PER_NODE=$(( (TOTAL_MEM * 2 / 3) / NUM_NODES ))
DISK_PER_NODE=$(( (TOTAL_DISK / 1024 / 1024 * 2 / 3) / NUM_NODES ))

# Мінімальні значення
if [ "$CPUS_PER_NODE" -lt 2 ]; then CPUS_PER_NODE=2; fi
if [ "$MEM_PER_NODE" -lt 4096 ]; then MEM_PER_NODE=4096; fi
if [ "$DISK_PER_NODE" -lt  4 ]; then DISK_PER_NODE=4; fi

echo "🚀 Створюємо кластер Minikube ($NUM_NODES ноди):"
echo "  CPU на ноду: $CPUS_PER_NODE"
echo "  RAM на ноду: ${MEM_PER_NODE}MB"
echo "  Диск на ноду: ${DISK_PER_NODE}GB"

# --- Старт Minikube ---
minikube start \
  --nodes=$NUM_NODES \
  --cpus=$CPUS_PER_NODE \
  --memory=${MEM_PER_NODE} \
  --disk-size=${DISK_PER_NODE}g \
  --driver=virtualbox

# --- Перевірка ---
echo "✅ Кластер створено. Ноди:"
kubectl get nodes -o wide

# --- Увімкнення аддонів ---
echo "🔧 Встановлюємо addons (metrics-server, ingress, dashboard)..."
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard

# --- Чекаємо на ingress controller ---
echo "⏳ Очікуємо готовності ingress-nginx..."
kubectl wait --namespace ingress-nginx \
  --for=condition=Available deployment ingress-nginx-controller \
  --timeout=180s

echo "✅ Усе готово!"
echo "🔎 Перевірка аддонів:"
kubectl get pods -A | grep -E "metrics-server|ingress|dashboard"

echo "🎯 Запуск Dashboard:"
echo "  minikube dashboard --url"

