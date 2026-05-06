import 'package:flutter/material.dart';
import 'video_item.dart';

class VideoScrollPage extends StatefulWidget {
  const VideoScrollPage({super.key});

  @override
  State<VideoScrollPage> createState() => _VideoScrollPageState();
}

class _VideoScrollPageState extends State<VideoScrollPage> {
  final List<String> videoUrls = [
    'https://assets.mixkit.co/videos/10428/10428-720.mp4',  // jus d'orange
    'https://assets.mixkit.co/videos/12171/12171-720.mp4',  // parmesan spaghetti
    'https://assets.mixkit.co/videos/47335/47335-720.mp4',  // glace plasticine
    'https://assets.mixkit.co/videos/10427/10427-720.mp4',  // baies rouges bol
    'https://assets.mixkit.co/videos/26094/26094-720.mp4',  // sandwich coupé
    'https://assets.mixkit.co/4dvkfbzfjzsgcceuaa7w6wxxmviv',// pique-nique
    'https://assets.mixkit.co/videos/10432/10432-720.mp4',  // eau de coco
    'https://assets.mixkit.co/videos/10429/10429-720.mp4',  // tranche orange
    'https://assets.mixkit.co/videos/50800/50800-720.mp4',  // orange & pamplemousse
    'https://assets.mixkit.co/videos/40534/40534-720.mp4',  // homme coupe tomate
    'https://assets.mixkit.co/videos/47331/47331-720.mp4',  // plasticine glace 2
    'https://assets.mixkit.co/videos/42944/42944-720.mp4',  // grains de café
    'https://assets.mixkit.co/videos/4925/4925-720.mp4',    // bière servie
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoItem(url: videoUrls[index]);
        },
      ),
    );
  }
}