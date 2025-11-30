import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilePage({
    super.key,
    this.name = "Jean Dupont",
    this.email = "name@gmail.com",
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // valeurs éditables
  String _phone = "Ajouter un numéro";
  String _birthDate = "Ajouter ta date de naissance";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            collapsedHeight: 80,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            shadowColor: Colors.black12,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mon Profil',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildStatsCard(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(),
                  const SizedBox(height: 24),
                  _buildPersonalInfo(),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar simple
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF667EEA),
                width: 3,
              ),
              color: const Color(0xFF667EEA).withOpacity(0.15),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 48,
                color: Color(0xFF667EEA),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nom + email (mn Register)
          Column(
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF667EEA).withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Color(0xFF667EEA),
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Compte vérifié',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ STATS ============
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.insights,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('12', 'Journaux', Icons.book_outlined),
              _buildStatItem('28', 'Humeurs', Icons.emoji_emotions_outlined),
              _buildStatItem('15', 'Succès', Icons.workspace_premium_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============ PARAMÈTRES ============
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Gérer les alertes',
                color: const Color(0xFF667EEA),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: 'Confidentialité',
                subtitle: 'Contrôler vos données',
                color: const Color(0xFF10B981),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.palette_outlined,
                title: 'Apparence',
                subtitle: 'Thème et couleurs',
                color: const Color(0xFFF59E0B),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Aide & Support',
                subtitle: 'FAQ et assistance',
                color: const Color(0xFFEF4444),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey,
          size: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  // ============ INFORMATIONS PERSO ============
  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoItem(
                icon: Icons.person_outline,
                label: 'Nom complet',
                value: widget.name,
                onEdit: null, // ma kaytbdlch hna
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.email_outlined,
                label: 'Adresse email',
                value: widget.email,
                onEdit: null,
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: _phone,
                onEdit: () => _editTextField(
                  title: "Téléphone",
                  initialValue: _phone == "Ajouter un numéro" ? "" : _phone,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) {
                    setState(() {
                      _phone = value.isEmpty ? "Ajouter un numéro" : value;
                    });
                  },
                ),
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.cake_outlined,
                label: 'Date de naissance',
                value: _birthDate,
                onEdit: () => _editTextField(
                  title: "Date de naissance",
                  initialValue: _birthDate == "Ajouter ta date de naissance"
                      ? ""
                      : _birthDate,
                  keyboardType: TextInputType.datetime,
                  onSaved: (value) {
                    setState(() {
                      _birthDate = value.isEmpty
                          ? "Ajouter ta date de naissance"
                          : value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667EEA),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: 16,
              ),
              onPressed: onEdit, // null => icon disabled
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editTextField({
    required String title,
    required String initialValue,
    required TextInputType keyboardType,
    required void Function(String) onSaved,
  }) async {
    final controller = TextEditingController(text: initialValue);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Entrez $title",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                onSaved(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  // ============ LOGOUT ============
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: déconnexion (Navigator.pushReplacement vers LoginPage, etc.)
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.05),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
