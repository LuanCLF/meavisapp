import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  final logger = Logger();
  void _launchEmail() async {
    try {
      await launchUrl(Uri(
        scheme: 'mailto',
        path: 'lclfdev@gmail.com',
        query: 'subject=Contato&body=Olá',
      ));
    } catch (e) {
      logger.e(e);
    }
  }

  void _launchWhatsApp() async {
    try {
      await launchUrl(Uri(
        scheme: 'https',
        path: 'wa.me/5584987166835',
        query: 'text=Olá',
      ));
    } catch (e) {
      logger.e(e);
    }
  }

  void _launchSite() async {
    try {
      await launchUrl(Uri(
        scheme: 'https',
        path: 'luanclf.me',
      ));
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: EdgeInsets.all(20),
      children: [
        Center(
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Sobre',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 56,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'O MeAvisa é um aplicativo que tem como objetivo ajudar a comunidade a se manter informada sobre as notícias mais recentes e relevantes da cidade',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
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
                  ]),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Desenvolvido por Luan Charlys:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Nascido em Martins - RN, desenvolvedor de software e entusiasta de tecnologia',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Meu objetivo é conectar a gestão pública com a população, através de tecnologia',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: _launchEmail,
                              style: ButtonStyle(
                                side: WidgetStateProperty.all<BorderSide>(
                                  BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 5,
                                children: [
                                  Icon(Icons.email),
                                  Text("Email"),
                                ],
                              )),
                        ),
                        SizedBox(
                          width: 140,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: _launchWhatsApp,
                              style: ButtonStyle(
                                side: WidgetStateProperty.all<BorderSide>(
                                  BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 5,
                                children: [
                                  Icon(Icons.phone),
                                  Text("WhatsApp"),
                                ],
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onPressed: _launchSite,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 5,
                            children: [
                              Icon(
                                Icons.computer,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              Text(
                                'Site',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )),
                    )
                  ],
                )
              ],
            ),
          ),
        )
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
