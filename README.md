# SOS Cidade - Gerenciador de Chamados Urbanos

Aplicativo móvel para gerenciamento de chamados de infraestrutura urbana, desenvolvido em Flutter com Provider, SQLite e Material 3.

## 🏗️ Estrutura do Projeto

```
lib/
├── models/                    # Modelos de dados
│   └── chamado_model.dart    # Modelo de Chamado com enums
├── database/                  # Camada de banco de dados
│   └── database_helper.dart  # CRUD do SQLite
├── providers/                 # Gerenciamento de estado
│   └── chamado_provider.dart # Provider com regras de negócio
├── screens/                   # Telas principais
│   ├── dashboard_screen.dart # Tela inicial
│   ├── cadastro_screen.dart  # Formulário de cadastro
│   └── detalhes_screen.dart  # Detalhes e edição
├── widgets/                   # Componentes reutilizáveis
│   ├── chamado_card.dart     # Card de chamado
│   ├── status_card.dart      # Card de status
│   └── custom_textfield.dart # Campo de texto customizado
├── core/                      # Utilitários e tema
│   ├── app_theme.dart        # Tema Material 3
│   └── validators.dart       # Validações
└── main.dart                  # Entrada da aplicação
```

## 📋 Divisão da Equipe (9 Pessoas)

| Pessoa | Função | Arquivo(s) | Responsabilidades |
|--------|--------|-----------|-------------------|
| 1 | **Integração/Main** | `main.dart`, `pubspec.yaml` | Integração dos módulos, dependências |
| 2 | **SQLite** | `database/database_helper.dart` | CRUD, queries, contadores |
| 3 | **Model/Regras** | `models/chamado_model.dart` | Estrutura, enums, métodos auxiliares |
| 4 | **Provider** | `providers/chamado_provider.dart` | Estado, lógica de negócio, notificações |
| 5 | **Dashboard** | `screens/dashboard_screen.dart` | Tela inicial, cards, lista |
| 6 | **Cadastro** | `screens/cadastro_screen.dart` | Formulário, validações, salvamento |
| 7 | **Widgets/UI** | `widgets/`, `core/app_theme.dart` | Cards, theme, componentes |
| 8 | **Extras** | - | Busca, filtros, dark mode, gráficos |
| 9 | **Testes** | `test/` | Testes unitários e de integração |

## 🎯 Funcionalidades Obrigatórias

### Dashboard
- ✅ Total de chamados
- ✅ Cards de status (Aberto, Em Progresso, Críticos)
- ✅ Lista ordenada (críticos e alta prioridade no topo)
- ✅ Data/hora de criação
- ✅ Alerta visual quando > 5 críticos

### Cadastro
- ✅ Formulário com validações
- ✅ Campo obrigatório: Título (única)
- ✅ Campo obrigatório: Descrição
- ✅ Campo obrigatório: Bairro
- ✅ Salvamento automático no SQLite

### Regras de Negócio
- ✅ Críticos no topo
- ✅ Alta prioridade no topo
- ✅ Título não repete
- ✅ Descrição obrigatória
- ✅ Bairro obrigatório
- ✅ Concluído não edita
- ✅ Alerta > 5 críticos
- ✅ Cálculo automático de tempo em aberto

## 🚀 Como Começar

### Instalação
```bash
# 1. Clonar o repositório
git clone [repo-url]
cd Atividade_ProjetoMobile

# 2. Instalar dependências
flutter pub get

# 3. Rodar o app
flutter run
```

### Instalação em Dev
```bash
# Build para Android
flutter build apk

# Build para iOS
flutter build ios
```

## 📦 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0        # State management
  sqflite: ^2.3.0         # SQLite
  path: ^1.8.0            # Path handling
  intl: ^0.19.0           # Localização/Formatação
```

## 🎨 Design

- **Tema**: Material 3
- **Cores Primárias**: Verde (#2E7D32), Azul (#1976D2)
- **Cores de Status**: Aberto (Verde), Em Progresso (Azul), Aguardando (Laranja), Concluído (Verde Escuro)
- **Cores de Prioridade**: Baixa (Verde), Média (Amarelo), Alta (Laranja), Crítica (Vermelho)

## 🔄 Fluxo de Desenvolvimento

1. ✅ Estrutura (pastas, pubspec.yaml)
2. ✅ Model (chamado_model.dart com enums)
3. ✅ SQLite (database_helper.dart - CRUD)
4. ✅ Provider (chamado_provider.dart - estado e regras)
5. ⏳ Cadastro (formulário com validações)
6. ⏳ Dashboard (tela inicial com cards)
7. ⏳ Extras (busca, filtros, etc)
8. ⏳ Testes (unitários e integração)

## 📱 Modelos de Dados

### Chamado
```dart
ChamadoModel {
  id: int,
  titulo: String (único),
  descricao: String,
  categoria: CategoriaChamado,
  prioridade: PrioridadeChamado,
  bairro: String,
  responsavel: String,
  dataCriacao: DateTime,
  dataResolucao: DateTime?,
  status: StatusChamado,
  observacoes: String?
}
```

### Enums
```dart
StatusChamado: aberto, emProgresso, aguardando, concluido
PrioridadeChamado: baixa, media, alta, critica
CategoriaChamado: asfalto, iluminacao, drenagem, calçada, manutenção, outro
```

## 🛠️ Ferramentas Recomendadas

- **IDE**: Android Studio + Flutter Plugin
- **Emulador**: Android Studio Emulator ou iOS Simulator
- **Banco de Dados**: DB Browser for SQLite (para debug)
- **Versionamento**: Git + GitHub

## ✅ Checklist de Entrega

- [ ] Estrutura criada
- [ ] Model implementado
- [ ] Database funcionando
- [ ] Provider gerenciando estado
- [ ] Tela de cadastro completa
- [ ] Dashboard com cards e lista
- [ ] Tela de detalhes
- [ ] Todas as regras de negócio implementadas
- [ ] Sem erros de compilação
- [ ] Testado em emulador
- [ ] UI limpa e responsiva

## 📞 Contato & Suporte

Para dúvidas ou problemas, consulte:
- Documentação Flutter: https://flutter.dev/docs
- Provider Package: https://pub.dev/packages/provider
- SQLite: https://pub.dev/packages/sqflite

---

**Versão**: 1.0.0  
**Data**: 28 de maio de 2026  
**Status**: Em Desenvolvimento 🚀
