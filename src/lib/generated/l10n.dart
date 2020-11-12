// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Kudos`
  String get appName {
    return Intl.message(
      'Kudos',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Sign in via Google`
  String get signIn {
    return Intl.message(
      'Sign in via Google',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to view your achievements`
  String get notSignedIn {
    return Intl.message(
      'Sign in to view your achievements',
      name: 'notSignedIn',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get people {
    return Intl.message(
      'People',
      name: 'people',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Make the name unique`
  String get editName {
    return Intl.message(
      'Make the name unique',
      name: 'editName',
      desc: '',
      args: [],
    );
  }

  /// `Make the description meaningful`
  String get editDescription {
    return Intl.message(
      'Make the description meaningful',
      name: 'editDescription',
      desc: '',
      args: [],
    );
  }

  /// `Make the image recognizable`
  String get editImage {
    return Intl.message(
      'Make the image recognizable',
      name: 'editImage',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Add a picture`
  String get fileIsNullErrorMessage {
    return Intl.message(
      'Add a picture',
      name: 'fileIsNullErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add a description`
  String get descriptionIsNullErrorMessage {
    return Intl.message(
      'Add a description',
      name: 'descriptionIsNullErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add a name`
  String get nameIsNullErrorMessage {
    return Intl.message(
      'Add a name',
      name: 'nameIsNullErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get generalErrorMessage {
    return Intl.message(
      'Something went wrong',
      name: 'generalErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Your comment`
  String get writeAComment {
    return Intl.message(
      'Your comment',
      name: 'writeAComment',
      desc: '',
      args: [],
    );
  }

  /// `Global Progress`
  String get achievementStatisticsTitle {
    return Intl.message(
      'Global Progress',
      name: 'achievementStatisticsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Holders`
  String get achievementHoldersTitle {
    return Intl.message(
      'Holders',
      name: 'achievementHoldersTitle',
      desc: '',
      args: [],
    );
  }

  /// `No one has ever received this achievement`
  String get achievementHoldersEmptyPlaceholder {
    return Intl.message(
      'No one has ever received this achievement',
      name: 'achievementHoldersEmptyPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `No achievements yet`
  String get profileAchievementsEmptyPlaceholder {
    return Intl.message(
      'No achievements yet',
      name: 'profileAchievementsEmptyPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get achievementOwnerTitle {
    return Intl.message(
      'Owner',
      name: 'achievementOwnerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add people`
  String get addPeople {
    return Intl.message(
      'Add people',
      name: 'addPeople',
      desc: '',
      args: [],
    );
  }

  /// `Create team`
  String get createTeam {
    return Intl.message(
      'Create team',
      name: 'createTeam',
      desc: '',
      args: [],
    );
  }

  /// `Edit team`
  String get editTeam {
    return Intl.message(
      'Edit team',
      name: 'editTeam',
      desc: '',
      args: [],
    );
  }

  /// `Required field`
  String get requiredField {
    return Intl.message(
      'Required field',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Team`
  String get team {
    return Intl.message(
      'Team',
      name: 'team',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `This user is not part of any team yet`
  String get userTeamsEmptyPlaceholder {
    return Intl.message(
      'This user is not part of any team yet',
      name: 'userTeamsEmptyPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Admins`
  String get admins {
    return Intl.message(
      'Admins',
      name: 'admins',
      desc: '',
      args: [],
    );
  }

  /// `Teams`
  String get teams {
    return Intl.message(
      'Teams',
      name: 'teams',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete this achievement?`
  String get deleteAchievementWarning {
    return Intl.message(
      'Do you really want to delete this achievement?',
      name: 'deleteAchievementWarning',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete this team? All team's achievements will be removed as well`
  String get deleteTeamWarning {
    return Intl.message(
      'Do you really want to delete this team? All team\'s achievements will be removed as well',
      name: 'deleteTeamWarning',
      desc: '',
      args: [],
    );
  }

  /// `Achievements`
  String get achievements {
    return Intl.message(
      'Achievements',
      name: 'achievements',
      desc: '',
      args: [],
    );
  }

  /// `Create your own rewards and give them to your colleagues!`
  String get createYourOwnAchievements {
    return Intl.message(
      'Create your own rewards and give them to your colleagues!',
      name: 'createYourOwnAchievements',
      desc: '',
      args: [],
    );
  }

  /// `Create your teams and invite your colleagues to join them!`
  String get createYourOwnTeams {
    return Intl.message(
      'Create your teams and invite your colleagues to join them!',
      name: 'createYourOwnTeams',
      desc: '',
      args: [],
    );
  }

  /// `Enter name`
  String get enterName {
    return Intl.message(
      'Enter name',
      name: 'enterName',
      desc: '',
      args: [],
    );
  }

  /// `Image size should be less than 0.5Mb`
  String get fileSizeTooBig {
    return Intl.message(
      'Image size should be less than 0.5Mb',
      name: 'fileSizeTooBig',
      desc: '',
      args: [],
    );
  }

  /// `Transfer achievement`
  String get transferAchievementTitle {
    return Intl.message(
      'Transfer achievement',
      name: 'transferAchievementTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to transfer this achievement to another user or another team?`
  String get transferAchievementDescription {
    return Intl.message(
      'Do you want to transfer this achievement to another user or another team?',
      name: 'transferAchievementDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transfer to %s?`
  String get transferAchievementToUserTitle {
    return Intl.message(
      'Transfer to %s?',
      name: 'transferAchievementToUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Transfer to %s team?`
  String get transferAchievementToTeamTitle {
    return Intl.message(
      'Transfer to %s team?',
      name: 'transferAchievementToTeamTitle',
      desc: '',
      args: [],
    );
  }

  /// `You will not have access to this achievement after the operation is complete`
  String get transferAchievementToUserWarning {
    return Intl.message(
      'You will not have access to this achievement after the operation is complete',
      name: 'transferAchievementToUserWarning',
      desc: '',
      args: [],
    );
  }

  /// `You might not have access to this achievement after the operation is complete`
  String get transferAchievementToTeamWarning {
    return Intl.message(
      'You might not have access to this achievement after the operation is complete',
      name: 'transferAchievementToTeamWarning',
      desc: '',
      args: [],
    );
  }

  /// `No comment`
  String get noComment {
    return Intl.message(
      'No comment',
      name: 'noComment',
      desc: '',
      args: [],
    );
  }

  /// `My Achievements`
  String get myAchievements {
    return Intl.message(
      'My Achievements',
      name: 'myAchievements',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Search Members`
  String get searchMembers {
    return Intl.message(
      'Search Members',
      name: 'searchMembers',
      desc: '',
      args: [],
    );
  }

  /// `Search Admins`
  String get searchAdmins {
    return Intl.message(
      'Search Admins',
      name: 'searchAdmins',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get signOutConfirmationTitle {
    return Intl.message(
      'Are you sure?',
      name: 'signOutConfirmationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm that you really want to leave this super awesome app`
  String get signOutConfirmationMessage {
    return Intl.message(
      'Confirm that you really want to leave this super awesome app',
      name: 'signOutConfirmationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOutConfirmButton {
    return Intl.message(
      'Sign Out',
      name: 'signOutConfirmButton',
      desc: '',
      args: [],
    );
  }

  /// `Stay!`
  String get signOutCancelButton {
    return Intl.message(
      'Stay!',
      name: 'signOutCancelButton',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Error: %s`
  String get detailedError {
    return Intl.message(
      'Error: %s',
      name: 'detailedError',
      desc: '',
      args: [],
    );
  }

  /// `From: %s`
  String get from {
    return Intl.message(
      'From: %s',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `Received achievements: %i`
  String get receivedAchievements {
    return Intl.message(
      'Received achievements: %i',
      name: 'receivedAchievements',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileTabName {
    return Intl.message(
      'Profile',
      name: 'profileTabName',
      desc: '',
      args: [],
    );
  }

  /// `Teams`
  String get teamsTabName {
    return Intl.message(
      'Teams',
      name: 'teamsTabName',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get peopleTabName {
    return Intl.message(
      'People',
      name: 'peopleTabName',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get achievementsTabName {
    return Intl.message(
      'Library',
      name: 'achievementsTabName',
      desc: '',
      args: [],
    );
  }

  /// `Softeq`
  String get softeq {
    return Intl.message(
      'Softeq',
      name: 'softeq',
      desc: '',
      args: [],
    );
  }

  /// `%i of %i people`
  String get peopleProgress {
    return Intl.message(
      '%i of %i people',
      name: 'peopleProgress',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one user`
  String get userPickerEmptyMessage {
    return Intl.message(
      'Please select at least one user',
      name: 'userPickerEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one admin`
  String get teamMemberPickerEmptyMessage {
    return Intl.message(
      'Please select at least one admin',
      name: 'teamMemberPickerEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `No search results`
  String get searchEmptyPlaceholder {
    return Intl.message(
      'No search results',
      name: 'searchEmptyPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Access denied`
  String get accessDenied {
    return Intl.message(
      'Access denied',
      name: 'accessDenied',
      desc: '',
      args: [],
    );
  }

  /// `This team is private`
  String get privateTeam {
    return Intl.message(
      'This team is private',
      name: 'privateTeam',
      desc: '',
      args: [],
    );
  }

  /// `This achievement is private`
  String get privateAchievement {
    return Intl.message(
      'This achievement is private',
      name: 'privateAchievement',
      desc: '',
      args: [],
    );
  }

  /// `My Teams`
  String get myTeams {
    return Intl.message(
      'My Teams',
      name: 'myTeams',
      desc: '',
      args: [],
    );
  }

  /// `Other Teams`
  String get otherTeams {
    return Intl.message(
      'Other Teams',
      name: 'otherTeams',
      desc: '',
      args: [],
    );
  }

  /// `Enter team name`
  String get teamNamePlaceholder {
    return Intl.message(
      'Enter team name',
      name: 'teamNamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Enter team description`
  String get teamDescriptionPlaceholder {
    return Intl.message(
      'Enter team description',
      name: 'teamDescriptionPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Team with such name already exists. Please change the name and try again`
  String get teamNameExists {
    return Intl.message(
      'Team with such name already exists. Please change the name and try again',
      name: 'teamNameExists',
      desc: '',
      args: [],
    );
  }

  /// `Access Level`
  String get accessLevel {
    return Intl.message(
      'Access Level',
      name: 'accessLevel',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get accessLevelPublic {
    return Intl.message(
      'Public',
      name: 'accessLevelPublic',
      desc: '',
      args: [],
    );
  }

  /// `Protected`
  String get accessLevelProtected {
    return Intl.message(
      'Protected',
      name: 'accessLevelProtected',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get accessLevelPrivate {
    return Intl.message(
      'Private',
      name: 'accessLevelPrivate',
      desc: '',
      args: [],
    );
  }

  /// `Everyone can view and send this team's achievements`
  String get accessLevelPublicDescription {
    return Intl.message(
      'Everyone can view and send this team\'s achievements',
      name: 'accessLevelPublicDescription',
      desc: '',
      args: [],
    );
  }

  /// `Everyone can view this team's achievements, but only team members can send them`
  String get accessLevelProtectedDescription {
    return Intl.message(
      'Everyone can view this team\'s achievements, but only team members can send them',
      name: 'accessLevelProtectedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Only team members can view and send this team's achievements`
  String get accessLevelPrivateDescription {
    return Intl.message(
      'Only team members can view and send this team\'s achievements',
      name: 'accessLevelPrivateDescription',
      desc: '',
      args: [],
    );
  }

  /// `(you)`
  String get youLabel {
    return Intl.message(
      '(you)',
      name: 'youLabel',
      desc: '',
      args: [],
    );
  }

  /// `Oops, the Kudos cannot be sent`
  String get cannotBeSentTitle {
    return Intl.message(
      'Oops, the Kudos cannot be sent',
      name: 'cannotBeSentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Kudos of the private team can be granted only to its members.\n\nPlease add someone to the team and try again.`
  String get cannotBeSentMessage {
    return Intl.message(
      'Kudos of the private team can be granted only to its members.\n\nPlease add someone to the team and try again.',
      name: 'cannotBeSentMessage',
      desc: '',
      args: [],
    );
  }

  /// `Update is Required`
  String get updateRequired {
    return Intl.message(
      'Update is Required',
      name: 'updateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please update your app to the latest version to continue.`
  String get updateRequiredMessage {
    return Intl.message(
      'Please update your app to the latest version to continue.',
      name: 'updateRequiredMessage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}