import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:imagelister/data/component/imagetile.dart';
import 'package:imagelister/presentation/home/cubit/home_cubit.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
            child: Column(
          children: [
            const Text("All"),
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.black),
            )
          ],
        )),
        backgroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => HomeCubit(context),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();
            if (state is HomeLoading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state is HomeError) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            } else if (state is HomeLoaded) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  itemCount: state.images.length,
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    final dynamicHeight = (100 + (index % 10) * 20).toDouble();
                    return ImageTile(
                      onTap: () {
                        cubit.downloadImage(image.src!.original!);
                      },
                      url: image.src!.large!,
                      height: dynamicHeight,
                    );
                  },
                ),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
