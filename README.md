
# Heart PPG – Medidor de Frequência Cardíaca por PPG

Um aplicativo Flutter que mede sua frequência cardíaca usando a câmera do celular pelo método PPG (fotopletismografia).

---

## 🚀 Funcionalidades

- **Medição de BPM:** Use a câmera traseira + flash para medir sua frequência cardíaca.
- **Histórico de medições:** Visualize todas as medições feitas, com data, BPM e mini gráfico do sinal.
- **Gráfico em tempo real:** Veja o sinal PPG enquanto mede.
- **Interface moderna:** Foco em usabilidade e visual bonito.
- **Swipe para deletar histórico:** Remova registros facilmente.

---

## 🧑‍💻 Como funciona

1. **O usuário cobre a lente e flash com o dedo.**
2. O app captura frames da câmera, extrai a intensidade do canal vermelho (luz que atravessa o dedo).
3. Gera um sinal PPG (variação do fluxo sanguíneo).
4. Processa o sinal para detectar batimentos (picos) e calcular o BPM.
5. Mostra na tela o valor de BPM, junto com gráfico em tempo real.
6. Salva cada medição no histórico, permitindo consultar depois.

---

## 📱 Telas principais

- **Home:** Botão para iniciar medição ou ver histórico.
- **Medição PPG:** Instruções, gráfico, BPM em tempo real.
- **Histórico:** Lista das medições anteriores, com BPM, data/hora, mini gráfico e swipe-to-delete.

---

## 🏗️ Arquitetura & Estrutura

- **Flutter + Dart 100%**
- Arquitetura por camadas: separação de UI, serviços, modelos, utilitários e widgets
- Principais pastas:
    - `lib/pages/` – telas (home, histórico, etc)
    - `lib/services/` – serviços de câmera, PPG, histórico
    - `lib/models/` – modelos de dados (`HeartRateSample`)
    - `lib/utils/` – processamento de sinal (cálculo de BPM)
    - `lib/widgets/` – gráficos reutilizáveis

---

## 🛠️ Linguagens e Tecnologias

- **Linguagem:**  
  - [Dart](https://dart.dev/) (100% do código da aplicação)
- **Framework:**  
  - [Flutter](https://flutter.dev/) (para apps Android e iOS)
- **Bibliotecas principais:**  
  - [`camera`](https://pub.dev/packages/camera) – captura de frames e controle da câmera
  - [`wakelock_plus`](https://pub.dev/packages/wakelock_plus) – mantém a tela ligada durante a medição
- **Arquitetura:**  
  - Separação em camadas: UI, Serviços, Modelos, Utils e Widgets
  - Modular, escalável e fácil de testar
- **Plataformas:**  
  - Android (com suporte a flash/câmera)
  - iOS (com suporte a flash/câmera)

---

## 📦 Tecnologias Usadas

![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white)

- **Dart** + **Flutter**
- Bibliotecas: camera, wakelock_plus

---

## 🛠️ Instalação e uso

Pré-requisitos:  
- Flutter 3.x  
- Dart 3.x  
- Dispositivo Android/iOS físico **(precisa de câmera e flash!)**

**Clone e instale as dependências:**

```bash
git clone https://github.com/SEU-USUARIO/heart_ppg.git
cd heart_ppg
flutter pub get
```

**Rode no dispositivo:**

```bash
flutter run
```

Se precisar, conecte seu celular por USB ou use emulador com câmera.

---

## 🗂️ Principais arquivos

- `main.dart` – inicialização do app, setup de câmera
- `camera_service.dart` – gerencia câmera e flash
- `ppg_service.dart` – coleta frames, calcula BPM
- `signal_processing.dart` – algoritmos de PPG
- `history_service.dart` – histórico de medições
- `heart_rate_sample.dart` – modelo de medição

---

## 👨‍🔬 Algoritmo PPG

- Usa frames em tempo real, extrai o canal vermelho
- Gera um vetor (sinal)
- Detecta picos para calcular BPM usando intervalos entre batidas

---

## 💡 Detalhes técnicos

- `camera` para captura de imagem
- `wakelock_plus` para manter a tela ligada
- Código limpo, modular, fácil de evoluir
- Fácil adaptar para novas features: exportar histórico, insights, login etc.

---

## 🖼️ Exemplo de uso

1. Abra o app e toque em “Medir frequência cardíaca”
2. Cubra a câmera traseira + flash com o dedo
3. Aguarde o app mostrar o BPM (aparece gráfico ao vivo)
4. Confira suas medições em “Histórico”

---

## 📄 Licença

MIT

---

**Desenvolvido por [Nayderson](https://github.com/Nerdzter)**
