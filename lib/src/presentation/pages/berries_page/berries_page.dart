import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poke_app/src/data/remote_data/data_providers/berry_provider.dart';
import 'package:poke_app/src/domain/models/berry_model.dart';
import 'package:poke_app/src/domain/models/item_model.dart';
import 'package:poke_app/src/domain/models/results_model.dart';
import 'package:poke_app/src/presentation/app/constants/assets.dart';
import 'package:poke_app/src/presentation/app/constants/methods.dart';
import 'package:poke_app/src/presentation/app/lang/l10n.dart';
import 'package:poke_app/src/presentation/app/theme/colors.dart';
import 'package:poke_app/src/presentation/pages/berries_page/widgets/berry_container_widget.dart';
import 'package:poke_app/src/presentation/pages/pokemon_page/widgets/pokemon_container_widget.dart';
import 'package:poke_app/src/presentation/widgets/loading_widget.dart';

class BerriesPage extends StatefulWidget {
  const BerriesPage({Key? key}) : super(key: key);

  @override
  State<BerriesPage> createState() => _BerriesPageState();
}

class _BerriesPageState extends State<BerriesPage> {
  String _textToSearch = "";
  int _cantidadDeBayas = 0;

  Future<void> _getParams() async {
    ResultsModel resultsModel = await BerryProvider().getBerries();

    setState(() {
      _cantidadDeBayas = resultsModel.count ?? 0;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _getParams();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            S.of(context).berries + " (" + _cantidadDeBayas.toString() + ")",
            style: Theme.of(context).textTheme.headline6),
      ),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: /* Image.asset(
                    Assets.assetsImagesPokesearch,
                    width: 30,
                    height: 30,
                  ) */
                      Container(
                    height: 90,
                    width: MediaQuery.of(context).size.width * 0.5,
                    /* decoration: BoxDecoration(
                        image: const DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                svgProvider.Svg(Assets.assetsImagesPikachuSvg)),
                        borderRadius: BorderRadius.circular(20.0)), */
                  ),
                ),
                /*  SvgPicture.asset(
                    Assets.assetsImagesPikachuSvg,
                    width: 80,
                    height: 80,
                  ) */
                /* SvgPicture.asset(Assets.assetsImagesPikachuSvg) */

                Expanded(
                  flex: 2,
                  child: TextField(
                    cursorColor: PokeColor().shadowBlue,
                    style: Theme.of(context).textTheme.bodyText2,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      fillColor: PokeColor().softBlue,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: S.of(context).search,
                      hintText: S.of(context).id_name,
                      labelStyle: Theme.of(context).textTheme.bodyText2,
                    ),
                    onSubmitted: (valor) {
                      setState(() {
                        _textToSearch = valor;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          _textToSearch == ""
              ? Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: FutureBuilder(
                    future: BerryProvider().getBerries(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: LoadingWidget());
                      } else {
                        ResultsModel berriesModel = snapshot.data!;
                        List<Result>? results = berriesModel.results ?? [];

                        return ListaBerries(
                          results: results,
                          // siguientePagina: PokemonProvider().getAllCharactersImpl,
                        );
                      }
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: FutureBuilder(
                    future: BerryProvider().getBerryByIdOrName(_textToSearch),
                    builder: (BuildContext context,
                        AsyncSnapshot<BerryModel> snapshot) {
                      if (!snapshot.hasData) {
                        return Column(
                          children: [
                            Expanded(
                              child: ClipRect(
                                  child: SvgPicture.asset(
                                      Assets.assetsImagesPikachuSvg)),
                            ),
                            Expanded(child: Text(S.of(context).noBerriesFound)),
                          ],
                        );
                      } else {
                        BerryModel berryModel = snapshot.data!;

                        return Center(
                            child: SizedBox(
                                height: 200,
                                width: 200,
                                child: pokemonContainer(
                                    context, berryModel.name!.capitalize())));
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class ListaBerries extends StatelessWidget {
  ListaBerries({
    Key? key,
    required this.results,
  }) : super(key: key);

  final List<Result> results;
  final _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.2,
  );
  // final Function siguientePagina;

  @override
  Widget build(BuildContext context) {
    /*   _pageController.addListener(() {
      if (_pageController.position.pixels >=
          _pageController.position.maxScrollExtent) {
            debugPrint("Siguiente Pagina");
      //  siguientePagina();
      }
    }); */

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20),
      shrinkWrap: true,
      //controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return berryContainer(
          context,
          results[index].name!,
        );
      },
    );
  }
}
