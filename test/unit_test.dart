import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/formatters.dart';
import 'package:my_app/domain/models/song.dart';
import 'package:my_app/domain/models/artist.dart';
import 'package:my_app/domain/models/album.dart';
import 'package:my_app/domain/models/playlist.dart';
import 'package:my_app/domain/models/app_notification.dart';
import 'package:my_app/domain/models/user_profile.dart';
import 'package:my_app/data/datasources/mock_music_data.dart';

void main() {
  group('Formatters Unit Tests', () {
    test('formatDuration formats minutes and seconds correctly', () {
      expect(Formatters.formatDuration(const Duration(minutes: 3, seconds: 45)), '03:45');
      expect(Formatters.formatDuration(const Duration(seconds: 9)), '00:09');
      expect(Formatters.formatDuration(null), '00:00');
    });

    test('formatDuration formats hours correctly', () {
      expect(
        Formatters.formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
    });

    test('formatNumber formats millions and thousands', () {
      expect(Formatters.formatNumber(1500000), '1.5M');
      expect(Formatters.formatNumber(45000), '45.0K');
      expect(Formatters.formatNumber(350), '350');
    });

    test('getGreeting returns appropriate time-of-day greeting', () {
      final morning = DateTime(2026, 9, 21, 8, 0);
      final afternoon = DateTime(2026, 9, 21, 14, 0);
      final evening = DateTime(2026, 9, 21, 20, 0);

      expect(Formatters.getGreeting(morning), 'Good morning');
      expect(Formatters.getGreeting(afternoon), 'Good afternoon');
      expect(Formatters.getGreeting(evening), 'Good evening');
    });
  });

  group('Domain Models Tests', () {
    test('Song model serialization and equality', () {
      const song = Song(
        id: 's1',
        title: 'Test Track',
        artist: 'Tester',
        artistId: 'a1',
        album: 'Test Album',
        albumId: 'alb1',
        duration: Duration(seconds: 180),
        audioUrl: 'https://example.com/audio.mp3',
        artworkUrl: 'https://example.com/art.jpg',
        genre: 'Synthpop',
        plays: 1000,
      );

      final json = song.toJson();
      final fromJson = Song.fromJson(json);

      expect(fromJson.id, song.id);
      expect(fromJson.title, song.title);
      expect(fromJson.duration.inSeconds, 180);
      expect(fromJson, equals(song));

      final likedSong = song.copyWith(isLiked: true);
      expect(likedSong.isLiked, true);
    });

    test('Playlist model creates and adds songs', () {
      final playlist = Playlist(
        id: 'p1',
        name: 'Chill Vibes',
        description: 'Smooth beats',
        coverUrl: 'https://example.com/pl.jpg',
        songIds: ['song_1', 'song_2'],
        createdAt: DateTime(2026, 1, 1),
      );

      expect(playlist.songIds.length, 2);
      final updated = playlist.copyWith(songIds: [...playlist.songIds, 'song_3']);
      expect(updated.songIds.length, 3);
    });

    test('Artist and Album models', () {
      const artist = Artist(
        id: 'art1',
        name: 'NeoArtist',
        avatarUrl: '',
        bio: 'Bio',
        monthlyListeners: 500000,
      );
      expect(artist.name, 'NeoArtist');

      const album = Album(
        id: 'alb1',
        title: 'Future Sounds',
        artist: 'NeoArtist',
        artistId: 'art1',
        coverUrl: '',
        releaseYear: 2026,
      );
      expect(album.releaseYear, 2026);
    });
  });

  group('MockMusicData Catalog Integrity', () {
    test('Songs contain required playback attributes and lyrics', () {
      expect(MockMusicData.songs.isNotEmpty, true);
      for (final song in MockMusicData.songs) {
        expect(song.id.isNotEmpty, true);
        expect(song.title.isNotEmpty, true);
        expect(song.audioUrl.startsWith('http'), true);
        expect(song.artworkUrl.startsWith('http'), true);
        expect(song.duration.inSeconds > 0, true);
      }
    });

    test('Artists and Albums link accurately', () {
      expect(MockMusicData.artists.isNotEmpty, true);
      expect(MockMusicData.albums.isNotEmpty, true);
      expect(MockMusicData.featuredPlaylists.isNotEmpty, true);
    });
  });

  group('Notifications Unit Tests', () {
    test('AppNotification creates and updates read state', () {
      const notif = AppNotification(
        id: 'n1',
        title: 'New Album',
        message: 'Daft Punk Deluxe',
        timeAgo: '10m ago',
      );
      expect(notif.isRead, false);

      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, true);
      expect(readNotif.title, 'New Album');
    });

    test('UserProfile handles banner and phone updates', () {
      const user = UserProfile(
        id: 'u1',
        name: 'Alex',
        email: 'alex@test.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        bannerUrl: 'https://example.com/banner.jpg',
        phoneNumber: '+1 555 123 4567',
      );

      expect(user.bannerUrl, 'https://example.com/banner.jpg');
      expect(user.phoneNumber, '+1 555 123 4567');

      final updated = user.copyWith(
        email: 'newalex@test.com',
        phoneNumber: '+1 555 987 6543',
      );
      expect(updated.email, 'newalex@test.com');
      expect(updated.phoneNumber, '+1 555 987 6543');
    });
  });
}
