import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final VoidCallback onRegister;

  const Home({super.key, required this.onRegister});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 40,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  'MEAVISA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 64,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: Text(
                    'Saiba tudo o que deseja da sua cidade!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Btn(
                  onRegister: onRegister,
                ),
                SizedBox(
                  width: 300,
                  child: Column(children: <Widget>[
                    Text(
                      "Você pode receber notificações de:",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      spacing: 5,
                      children: [
                        IcnText(iconData: Icons.construction, text: "Obras"),
                        IcnText(
                            iconData: Icons.energy_savings_leaf,
                            text: "Problemas de água/energia"),
                        IcnText(iconData: Icons.event, text: "Eventos"),
                        IcnText(iconData: Icons.local_hospital, text: "Saúde"),
                        IcnText(iconData: Icons.school, text: "Educação"),
                        IcnText(
                            iconData: Icons.local_police, text: "Segurança"),
                        IcnText(iconData: Icons.abc, text: "Concursos"),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                        "Receba notificações no seu WhatsApp ou Email e fique por dentro de tudo que acontece na sua cidade!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class IcnText extends StatelessWidget {
  final IconData iconData;
  final String text;

  const IcnText({super.key, required this.iconData, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        spacing: 5,
        children: [
          Icon(
            iconData,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(text),
        ],
      ),
    );
  }
}

class Btn extends StatefulWidget {
  final VoidCallback onRegister;

  const Btn({
    super.key,
    required this.onRegister,
  });

  @override
  State<Btn> createState() => _BtnState();
}

class _BtnState extends State<Btn> {
  bool _isLoading = false;

  void _handlePress() async {
    setState(() {
      _isLoading = true;
    });
    widget.onRegister();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        onPressed: _isLoading ? null : _handlePress,
        child: _isLoading
            ? CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary),
              )
            : Text(
                'Receber',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
