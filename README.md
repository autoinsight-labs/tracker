# Mottu Operator

<div align="center">
  
**Aplicativo iOS para localização e rastreamento de veículos usando tecnologia Beacon**

![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue)

</div>

## 📋 Sobre o Projeto

Mottu Operator é um aplicativo iOS nativo desenvolvido em SwiftUI que permite aos operadores localizar e rastrear veículos em um pátio usando tecnologia de Bluetooth Beacons (iBeacon). O app utiliza a proximidade de beacons instalados nos veículos para calcular distâncias em tempo real e auxiliar na localização física de veículos específicos.

## ✨ Funcionalidades

### 🚗 Lista de Veículos
- Visualização de todos os veículos disponíveis no pátio
- Exibição de informações do veículo (identificador, modelo e ano)
- Busca e filtro de veículos por identificador
- Indicação de distância em tempo real para cada veículo
- Estados de carregamento inteligentes (loading, encontrado, não encontrado)

### 📍 Rastreamento em Tempo Real
- Interface de rastreamento visual com indicador de proximidade
- Círculo animado que cresce conforme a distância aumenta
- Exibição de distância formatada (metros/centímetros)
- Indicadores de proximidade (immediate, near, far, unknown)
- Aviso quando o sinal está fraco
- Atualização contínua das medições

### 🎯 Precisão e Confiabilidade
- Algoritmo de suavização de distância (smoothing) para reduzir oscilações
- Filtro de precisão mínima para ignorar leituras imprecisas
- Sistema de timeout para detectar beacons não encontrados
- Suporte a múltiplos beacons simultâneos

## 🛠 Tecnologias Utilizadas

- **SwiftUI** - Framework moderno para construção de interfaces
- **CoreLocation** - Framework para detecção e ranging de beacons
- **Swift Observation** - Sistema de observação para gerenciamento de estado
- **iBeacon Technology** - Protocolo Bluetooth Low Energy para proximidade
- **iOS 17+** - Recursos modernos do iOS

## 🏗 Arquitetura

O projeto segue uma arquitetura MVVM (Model-View-ViewModel) com princípios de SwiftUI:

```
MottuOperator/
├── Models/
│   └── Vehicle.swift              # Modelo de dados do veículo
├── Services/
│   └── BeaconService.swift        # Serviço de detecção de beacons
├── Views/
│   ├── ContentView.swift          # View principal
│   ├── Vehicle/
│   │   ├── VehicleListView.swift      # Lista de veículos
│   │   └── VehicleListItemView.swift  # Item individual da lista
│   └── Tracker/
│       ├── TrackerView.swift              # View de rastreamento
│       ├── TrackerHeaderView.swift        # Cabeçalho do tracker
│       ├── ProximityIndicatorView.swift   # Indicador visual de proximidade
│       ├── DistanceDisplayView.swift      # Exibição da distância
│       ├── DistanceFormatter.swift        # Formatação de distâncias
│       └── TrackerDisplayConstants.swift  # Constantes de UI
└── MottuOperatorApp.swift         # Entry point do app
```

### Componentes Principais

#### 📦 Models
- **Vehicle**: Estrutura que representa um veículo com identificador, beacon data e informações do modelo

#### 🔧 Services
- **BeaconService**: Serviço observável responsável por:
  - Gerenciar permissões de localização
  - Iniciar/parar ranging de beacons
  - Calcular e suavizar distâncias
  - Detectar níveis de proximidade
  - Manter estado de múltiplos beacons

#### 🎨 Views
- **VehicleListView**: Lista principal com busca e navegação
- **TrackerView**: Interface de rastreamento com indicadores visuais
- **ProximityIndicatorView**: Círculo animado que representa proximidade
- **DistanceDisplayView**: Exibição formatada da distância e proximidade

## 🔍 Como Funciona

### Detecção de Beacons

1. **Configuração**: Cada veículo possui um beacon com UUID, Major e Minor únicos
2. **Ranging**: O app escaneia continuamente por beacons próximos
3. **Cálculo**: CoreLocation fornece distância estimada em metros
4. **Suavização**: Algoritmo de média móvel exponencial reduz oscilações
5. **Atualização**: Interface atualiza em tempo real com novas medições

### Algoritmo de Suavização

```swift
smoothed = old + (new - old) * smoothingFactor
```

- **Smoothing Factor**: 0.15 (15% da nova leitura)
- **Benefício**: Reduz ruído e fornece leitura mais estável
- **Trade-off**: Pequeno delay na atualização vs estabilidade

### Níveis de Proximidade

| Nível | Descrição | Distância Típica |
|-------|-----------|------------------|
| **Immediate** | Muito próximo | < 0.5m |
| **Near** | Próximo | 0.5m - 3m |
| **Far** | Longe | > 3m |
| **Unknown** | Desconhecido | Sinal não detectado |

## 📱 Requisitos

- iOS 17.0 ou superior
- Xcode 15.0 ou superior
- Dispositivo iOS com suporte a Bluetooth 4.0+ (beacons requerem hardware real, não funciona no simulador)
- Permissões de localização ("When In Use")

## 🚀 Como Executar

1. **Clone o repositório**
   ```bash
   git clone https://github.com/autoinsight-labs/tracker.git
   cd tracker
   ```

2. **Abra o projeto no Xcode**
   ```bash
   open MottuOperator.xcodeproj
   ```

3. **Configure permissões**
   - O app solicita permissão de localização automaticamente
   - Verifique que as permissões estão configuradas no Info.plist

4. **Execute no dispositivo**
   - Selecione um dispositivo físico (não simulador)
   - Pressione `Cmd + R` para build e executar

## 🔐 Permissões Necessárias

O app requer as seguintes permissões (já configuradas no Info.plist):

- `NSLocationWhenInUseUsageDescription` - Para detectar beacons próximos

## 🎯 Casos de Uso

### Operador de Pátio
1. Abre o app e visualiza lista de veículos
2. Vê distância em tempo real de cada veículo
3. Busca veículo específico pelo identificador
4. Toca no veículo para abrir rastreamento detalhado
5. Segue indicador visual para encontrar o veículo

### Gerente de Frota
1. Visualiza todos veículos disponíveis
2. Verifica quais estão próximos vs distantes
3. Identifica veículos não detectados (fora de alcance ou beacon com problema)

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

## 🎨 Interface do Usuário

### Design System
- **Cor primária**: Azul (fundo do tracker)
- **Cor de texto**: Branco (no tracker) / Preto (na lista)
- **Fontes**: SF Rounded para números grandes
- **Animações**: Suaves e responsivas
- **Acessibilidade**: Elementos combinados para leitores de tela

### Componentes Visuais
- Círculo de proximidade com crescimento animado
- Exibição grande e clara da distância
- Indicador textual de proximidade
- Lista com estados de carregamento

## 🔧 Configuração de Beacons

Para usar com beacons reais:

1. Configure o UUID do beacon (padrão: gerado randomicamente)
2. Defina valores únicos de Major e Minor para cada veículo
3. Atualize os dados dos veículos em `ContentView.swift`
4. Configure os beacons físicos com os mesmos parâmetros

### Exemplo de Beacon
```swift
Vehicle.BeaconData(
    id: UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")!,
    major: 10167,
    minor: 61958
)
```

## 👥 Equipe de Desenvolvimento

| Nome                      | RM       | E-mail                  | GitHub                                      | LinkedIn                                            |
| ------------------------- | -------- | ----------------------- | ------------------------------------------- | --------------------------------------------------- |
| Arthur Vieira Mariano     | RM554742 | arthvm@proton.me        | [@arthvm](https://github.com/arthvm)        | [arthvm](https://linkedin.com/in/arthvm/)           |
| Guilherme Henrique Maggiorini | RM554745 | guimaggiorini@gmail.com | [@guimaggiorini](https://github.com/guimaggiorini) | [guimaggiorini](https://linkedin.com/in/guimaggiorini/) |
| Ian Rossato Braga         | RM554989 | ian007953@gmail.com     | [@iannrb](https://github.com/iannrb)        | [ianrossato](https://linkedin.com/in/ianrossato/)   |

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos como parte do challenge da Mottu FIAP.

---

<div align="center">
Desenvolvido com ❤️ usando SwiftUI
</div>

