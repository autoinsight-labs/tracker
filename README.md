# Mottu Operator

<div align="center">
  
**Aplicativo iOS para gestão e rastreamento de frota com beacons, convites e cadastro de veículos.**

![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue)
![Firebase Auth](https://img.shields.io/badge/Firebase-Auth-yellow)

</div>

## 🧭 Índice
- [Visão Geral](#-visão-geral)
- [Principais Capacidades](#-principais-capacidades)
- [Stack Tecnológica](#-stack-tecnológica)
- [Fluxos do Produto](#-fluxos-do-produto)
- [Arquitetura](#-arquitetura)
- [Serviços e Integrações](#-serviços-e-integrações)
- [Pré-requisitos](#-pré-requisitos)
- [Configuração do Ambiente](#-configuração-do-ambiente)
- [Execução Rápida](#-execução-rápida)
- [Dados de Teste](#-dados-de-teste)
- [Internacionalização e Acessibilidade](#-internacionalização-e-acessibilidade)
- [Equipe](#-equipe)
- [Licença](#-licença)

## 📋 Visão Geral
O **Mottu Operator** é um aplicativo nativo para iOS, desenvolvido em SwiftUI, que auxilia operadores de pátios Mottu a administrar convites, cadastrar veículos e localizar motocicletas equipadas com beacons Bluetooth (iBeacon). O app combina autenticação via Firebase, consumo de API REST e tecnologia de proximidade para entregar uma experiência completa de operação em campo.

## ✨ Principais Capacidades
- **Autenticação segura**: fluxo de cadastro e login com validação de formulários e Firebase Authentication.
- **Gestão de convites**: listagem, aceitação e recusa de convites recebidos pelos operadores, com persistência do pátio ativo.
- **Operação de veículos**:
  - Lista com estados de carregamento, busca por placa e detalhes completos.
  - Cadastro de novos veículos com scanner de QR Code para dados do beacon.
  - Atualização de status, responsável e beacon diretamente pela API.
- **Rastreamento em tempo real**:
  - Visualização de proximidade com indicadores visuais e leitura suavizada.
  - Comunicação contínua com CoreLocation para ranging de beacons iBeacon.

## 🛠 Stack Tecnológica
- **SwiftUI & Observation** para UI declarativa reativa.
- **CoreLocation** para ranging de beacons e cálculo de distância.
- **AVFoundation** para leitura de QR Codes de beacons.
- **Firebase Authentication** (via Swift Package Manager) para login/cadastro.
- **Async/Await** + `Task` para operações assíncronas seguras.

## 🧱 Fluxos do Produto
### Autenticação
1. Usuário realiza cadastro com nome, e-mail e senha.
2. Validações de formulário orientam correções em tempo real.
3. Após cadastro ou login, o token do Firebase é reutilizado pelos serviços de rede.

### Convites do Pátio
1. Convites pendentes são carregados ao entrar no app.
2. Ao aceitar um convite, o pátio ativo é salvo localmente (`UserDefaults`).
3. Recusas são refletidas imediatamente na lista.

### Operação de Veículos
1. Lista mostra status, modelo e beacon associado.
2. Cadastro de novos veículos permite buscar responsáveis e escanear QR Code do beacon.
3. Serviços REST atualizam ou criam registros diretamente na API Mottu.

### Rastreamento com Beacon
1. Operador escolhe um veículo para abrir o modo tracker.
2. `BeaconService` inicia o ranging do beacon configurado.
3. Distâncias são suavizadas (EMA) e exibidas com indicação visual de proximidade.

## 🏗 Arquitetura
O projeto segue MVVM com injeção por ambiente (`@Environment`) e observabilidade (`@Observable`).

```
MottuOperator/
├── Models/                     # Modelos de domínio (Vehicle, Invite, YardEmployee...)
├── Services/                   # Camada de acesso a APIs, beacons e auth
│   ├── AuthService.swift       # Firebase Auth wrapper
│   ├── InviteService.swift     # Gestão de convites e pátio ativo
│   ├── VehicleService.swift    # CRUD de veículos e colaboradores
│   ├── BeaconService.swift     # Ranging e smoothing de beacons
│   ├── WebService.swift        # Cliente HTTP genérico com decode typed
│   ├── APIConfiguration.swift  # Resolução do endpoint base
│   └── YardStorage.swift       # Persistência local do ID do pátio
├── Shared/
│   └── Auth/                   # Regras de validação de formulários
├── Views/
│   ├── Auth/                   # Fluxos de Sign In / Sign Up
│   ├── Invite/                 # Pendências de convite
│   ├── Vehicle/                # Lista, detalhe e criação de veículos
│   └── Tracker/                # Telas e componentes do modo rastreador
└── MottuOperatorApp.swift      # Entry point com injeção de dependências
```

### Padrões adotados
- **ViewModels leves** utilizando serviços observáveis.
- **Networking** com `URLSession` estruturada e tratamento de erros customizado.
- **Tratamento de estados** (`loading`, `error`, `empty`) em views principais.
- **Injeção ambiente** facilita pré-visualizações e testes futuros.

## 🌐 Serviços e Integrações
| Serviço | Uso | Observações |
| ------- | --- | ----------- |
| Firebase Authentication | Cadastro/Login | Requer `GoogleService-Info.plist` configurado. |
| API REST Mottu | Convites, veículos, colaboradores | Endpoint base configurável via `API_BASE_URL`. |
| CoreLocation | Ranging iBeacon | Necessita permissão *When In Use*. |
| AVFoundation | Scanner QR Code | Necessita permissão de câmera. |

## 📱 Pré-requisitos
- macOS com **Xcode 15.0+** e SDK iOS 17.
- Dispositivo físico com Bluetooth 4.0+ (beacons não funcionam no simulador).
- Conta Firebase com projeto configurado para iOS.
- API Mottu disponível (local, staging ou produção).

## � Configuração do Ambiente
1. **Clonar o repositório**
   ```bash
   git clone https://github.com/autoinsight-labs/tracker.git
   cd tracker
   ```
2. **Firebase Authentication**
   - Crie um app iOS no console Firebase.
   - Baixe o `GoogleService-Info.plist` e copie para `MottuOperator/` (substitua o existente, se aplicável).
   - Habilite Email/Password em *Authentication > Sign-in method*.
3. **Endpoint da API**
   - Defina o valor do endpoint via Scheme (`Edit Scheme > Run > Arguments > Environment`: `API_BASE_URL=https://sua-api`) **ou** edite o `Info.plist` e atualize a chave `API_BASE_URL`.
4. **Permissões**
   - Verifique textos das chaves `NSLocationWhenInUseUsageDescription` e `NSCameraUsageDescription` em `Info.plist` para refletirem a política da sua empresa.
5. **Dependências SwiftPM**
   - Xcode fará o *resolve* automaticamente ao abrir o projeto. Certifique-se de ter acesso ao GitHub para os pacotes Firebase.

## 🚀 Execução Rápida
1. Abra o projeto:
   ```bash
   open MottuOperator.xcodeproj
   ```
2. Selecione um dispositivo físico.
3. Build & Run (`⌘ + R`).
4. Autorize localização e câmera quando solicitado.

## 🧪 Dados de Teste
O app inclui 8 veículos mockados para demonstração:

| Identificador | Modelo | Ano | Major | Minor |
|---------------|--------|-----|-------|-------|
| BRA0S17 | Mottu Model E | 2020 | 10167 | 61958 |
| BRA0S18 | Mottu Model E | 2021 | 10001 | 50001 |
| BRA0S19 | Mottu Model S | 2022 | 10002 | 50002 |
| BRA0S20 | Mottu Model S | 2023 | 10003 | 50003 |
| SPX1234 | Mottu Cargo | 2019 | 12000 | 62000 |
| SPX5678 | Mottu Cargo | 2020 | 12001 | 62001 |
| RIO4321 | Mottu City | 2018 | 13000 | 63000 |
| FOR9876 | Mottu City | 2022 | 14000 | 64000 |

## � Internacionalização e Acessibilidade
- Strings localizadas em `Localizable.xcstrings` facilitam traduções futuras.
- Componentes consideram leitura por VoiceOver (labels e combinações acessíveis).
- Layouts reagem a `Dynamic Type` e estados de carregamento com feedback visual.

## 👥 Equipe

| Nome                        | RM      | Turma    | E-mail                 | GitHub                                         | LinkedIn                                   |
|-----------------------------|---------|----------|------------------------|------------------------------------------------|--------------------------------------------|
| Arthur Vieira Mariano       | RM554742| 2TDSPF   | arthvm@proton.me       | [@arthvm](https://github.com/arthvm)           | [arthvm](https://linkedin.com/in/arthvm/)  |
| Guilherme Henrique Maggiorini| RM554745| 2TDSPF  | guimaggiorini@gmail.com| [@guimaggiorini](https://github.com/guimaggiorini) | [guimaggiorini](https://linkedin.com/in/guimaggiorini/) |
| Ian Rossato Braga           | RM554989| 2TDSPY   | ian007953@gmail.com    | [@iannrb](https://github.com/iannrb)           | [ianrossato](https://linkedin.com/in/ianrossato/)      |


## 📄 Licença
Projeto desenvolvido para fins acadêmicos no challenge FIAP x Mottu.

---

<div align="center">
Desenvolvido com ❤️ usando SwiftUI
</div>

