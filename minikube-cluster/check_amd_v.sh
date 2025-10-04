#!/bin/bash

# 🎨 Кольори
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

echo -e "${BOLD}${BLUE}🔍 Перевірка підтримки AMD-V (SVM) та готовності до VirtualBox...${RESET}"

# 1️⃣ Перевірка підтримки апаратної віртуалізації
if egrep -q '(svm|vmx)' /proc/cpuinfo; then
    echo -e "${GREEN}✅ CPU підтримує апаратну віртуалізацію (svm/vmx знайдено)${RESET}"
else
    echo -e "${RED}❌ CPU не підтримує апаратну віртуалізацію — VirtualBox працюватиме лише в повільному режимі.${RESET}"
    exit 1
fi

# 2️⃣ Перевірка, чи ввімкнено в BIOS/UEFI
if dmesg | grep -qi "svm.*enabled"; then
    echo -e "${GREEN}✅ AMD-V (SVM) увімкнено в BIOS/UEFI${RESET}"
elif dmesg | grep -qi "svm.*disabled"; then
    echo -e "${YELLOW}⚠️ AMD-V (SVM) ВИМКНЕНО в BIOS/UEFI — зайди в BIOS і увімкни SVM Mode.${RESET}"
    read -p "🔄 Відкрити офіційну інструкцію в браузері? (y/n): " ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        xdg-open "https://www.amd.com/en/support/kb/faq/pa-180" >/dev/null 2>&1 &
    fi
else
    echo -e "${YELLOW}ℹ️ Не вдалося визначити стан SVM через dmesg (можливо, логи очищені або ядро приховує цю інформацію)${RESET}"
fi

# 3️⃣ Перевірка, чи KVM займає AMD-V
if lsmod | grep -q kvm_amd; then
    echo -e "${YELLOW}⚠️ KVM активний (kvm_amd завантажено) — може блокувати VirtualBox${RESET}"
    read -p "🔧 Вивантажити модулі KVM прямо зараз? (y/n): " ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        sudo modprobe -r kvm_amd kvm && echo -e "${GREEN}✅ KVM відключено${RESET}"
    fi
else
    echo -e "${GREEN}✅ KVM не заважає VirtualBox${RESET}"
fi

# 4️⃣ Перевірка наявності VirtualBox
if command -v VBoxManage >/dev/null 2>&1; then
    echo -e "${GREEN}✅ VirtualBox встановлений${RESET}"
    echo -e "${BLUE}🔧 Перевірка доступних типів гостьових ОС...${RESET}"
    if VBoxManage list ostypes | grep -q "ID:.*64"; then
        echo -e "${GREEN}✅ 64-бітні гостьові ОС доступні у VirtualBox${RESET}"
    else
        echo -e "${RED}❌ 64-бітні гостьові ОС НЕ відображаються — AMD-V, ймовірно, вимкнено або зайнято.${RESET}"
    fi

    read -p "▶️ Хочеш одразу запустити VirtualBox? (y/n): " ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        virtualbox &
    fi
else
    echo -e "${YELLOW}⚠️ VirtualBox не знайдено у системі.${RESET}"
    read -p "📦 Встановити VirtualBox зараз? (y/n): " ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y virtualbox virtualbox-ext-pack
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y VirtualBox
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm virtualbox
        else
            echo -e "${YELLOW}⚠️ Не вдалося визначити пакетний менеджер — встанови VirtualBox вручну.${RESET}"
        fi
    fi
fi

echo -e "${BOLD}${GREEN}✅ Перевірка завершена!${RESET}"
