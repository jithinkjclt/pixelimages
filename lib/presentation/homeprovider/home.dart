import 'package:flutter/material.dart';
import 'package:imagelister/presentation/homeprovider/provider/homeprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:imagelister/data/component/imagetile.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

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
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text('Error: ${provider.errorMessage}'))
          : Column(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: provider.images.isNotEmpty
                ? Image(
                fit: BoxFit.fill,
                image: NetworkImage(
                    provider.images.first.src!.large!))
                : const SizedBox(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.builder(
                physics: BouncingScrollPhysics(), // Ensures scrolling
                gridDelegate:
                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: provider.images.length,
                itemBuilder: (context, index) {
                  final image = provider.images[index];
                  return ImageTile(
                    onTap: () {
                      provider.downloadImage(image.src!.original!);
                    },
                    url: image.src!.large!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
