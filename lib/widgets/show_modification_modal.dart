import 'package:divertidachat/main.dart';
import 'package:divertidachat/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future showModificationModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(children: [
          Selector<HomeState, TextFilter>(
            selector: (context, homeState) => homeState.activeTextFilter,
            builder: (context, activeFilter, child) {
              final homeState = Provider.of<HomeState>(context, listen: false);
              final filters = homeState.textFilters;
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                ),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: activeFilter == filters[index]
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    child: InkWell(
                      onTap: () {
                        homeState.setActiveTextFilter(filters[index]);
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(filters[index].emoji),
                            Text(
                              filters[index].name,
                              style: TextStyle(
                                color: activeFilter == filters[index]
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ]),
      );
    },
  );
}
