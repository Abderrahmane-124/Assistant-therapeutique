import 'package:flutter/material.dart';
import 'package:moodmate/models/quote_model.dart';
import 'package:moodmate/services/quote_service.dart';

class DailyQuoteWidget extends StatefulWidget {
  const DailyQuoteWidget({super.key});

  @override
  State<DailyQuoteWidget> createState() => _DailyQuoteWidgetState();
}

class _DailyQuoteWidgetState extends State<DailyQuoteWidget> with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  Quote? _currentQuote;
  bool _isLoading = true;
  bool _isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadDailyQuote();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyQuote() async {
    setState(() => _isLoading = true);
    try {
      final quote = await _quoteService.getDailyQuote();
      final isFav = await _quoteService.isFavorite(quote);
      setState(() {
        _currentQuote = quote;
        _isFavorite = isFav;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNewQuote() async {
    _animationController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() => _isLoading = true);
    try {
      final quote = await _quoteService.fetchRandomQuote();
      final isFav = await _quoteService.isFavorite(quote);
      setState(() {
        _currentQuote = quote;
        _isFavorite = isFav;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentQuote == null) return;

    if (_isFavorite) {
      await _quoteService.removeFromFavorites(_currentQuote!);
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Citation retirée des favoris'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      await _quoteService.addToFavorites(_currentQuote!);
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Citation ajoutée aux favoris'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[50]!,
            Colors.orange[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.format_quote,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Citation du jour",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isFavorite ? Colors.pink[100] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.pink[600] : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _loadNewQuote,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_currentQuote != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${_currentQuote!.content}"',
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '— ${_currentQuote!.author}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
