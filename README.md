# Previsão do Tempo

Atividade avaliativa da Aula 09 (Consumindo APIs remotas em Flutter) de
Desenvolvimento de software para dispositivos móveis II.

O app permite buscar uma cidade pelo nome e ver a previsão do tempo dela,
usando as APIs abertas do [Open-Meteo](https://open-meteo.com) (sem cadastro
nem chave).

## Como usar o app

1. Na tela inicial, digite o nome de uma cidade (ex.: `São Sebastião do
   Paraíso`) e toque na lupa ou no Enter do teclado.
2. Escolha a cidade na lista (até 10 resultados).
3. Na tela da previsão você vê:
   - **Agora:** temperatura, umidade, chuva e vento;
   - **Próximas horas:** 24 horas com temperatura e probabilidade de chuva;
   - **Próximos dias:** 7 dias com mínima, máxima, chuva e probabilidade.
4. Para atualizar, puxe a tela para baixo ou toque no botão de recarregar na
   barra superior.

Se a internet falhar, a tela mostra a mensagem de erro e o botão **Tentar
novamente**.

## Como rodar o projeto

Pré-requisitos: Flutter 3.41 ou superior (Dart 3.11) e um navegador Chrome,
ou um emulador/aparelho Android.

```bash
flutter pub get

# no navegador
flutter run -d chrome

# ou no Android
flutter run
```

Se o Flutter não conseguir abrir o Chrome (erro "Failed to launch browser"),
suba um servidor web e abra o endereço no seu navegador:

```bash
flutter run -d web-server --web-port 8080
```

Depois acesse `http://localhost:8080`.

## APIs utilizadas

| Para quê | Endereço |
| --- | --- |
| Buscar a cidade (latitude e longitude) | `https://geocoding-api.open-meteo.com/v1/search` |
| Previsão do tempo | `https://api.open-meteo.com/v1/forecast` |

Observação: no slide da aula o domínio do geocoding aparece como
`openmeteo.com`; o correto é `open-meteo.com`, com hífen.

## Estrutura do código

```
lib/
  main.dart                    ponto de entrada do app
  models/
    cidade.dart                Cidade.fromJson
    previsao.dart              ClimaAtual, PrevisaoHora, PrevisaoDia, Previsao
  services/
    clima_service.dart         buscarCidades() e buscarPrevisao()
  screens/
    busca_screen.dart          busca e lista de cidades
    previsao_screen.dart       previsão (carregando, erro e dados)
```

A organização segue a aula: o **model** representa o dado, o **service** faz a
requisição (com `timeout` e checagem do `statusCode`) e a **screen** só cuida
da tela, usando `FutureBuilder` para os três estados.

## Observações

- A permissão `INTERNET` está em
  `android/app/src/main/AndroidManifest.xml`. Sem ela o app funciona em debug,
  mas não no APK de release.
- Para gerar o APK de release: `flutter build apk --release`.
