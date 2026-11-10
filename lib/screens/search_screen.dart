import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/buku_provider.dart';
import 'detail_buku_screen.dart';

/// Screen pencarian buku: input dengan debounce 400ms → API ?search=
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<BukuProvider>().query;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final provider = context.read<BukuProvider>();
      provider.setQuery(value);
      await provider.loadFirst();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BukuProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _controller,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Cari judul, ISBN, atau nama penulis…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _controller.clear();
                        _onChanged(' ');
                        provider.reset();
                      },
                    ),
            ),
          ),
        ),
        Expanded(
          child: provider.loading && provider.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        provider.error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : provider.items.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Belum ada hasil pencarian.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      : Consumer<BukuProvider>(builder: (context, p, _) {
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            itemCount: p.items.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final buku = p.items[index];
                              return Semantics(
                                label: 'Detail ${buku.judul}',
                                button: true,
                                child: Card(
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.auto_stories_rounded,
                                        color: Color(0xFF1976D2)),
                                    title: Text(buku.judul),
                                    subtitle: Text(buku.namaPenulis),
                                    trailing: Text('Stok ${buku.stokTersedia}'),
                                    onTap: () async {
                                      final nav = Navigator.of(context);
                                      final provider = context.read<BukuProvider>();
                                      await nav.push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                DetailBukuScreen(bukuId: buku.id)),
                                      );
                                      if (mounted) {
                                        provider.loadFirst();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }),
        ),
      ],
    );
  }
}
