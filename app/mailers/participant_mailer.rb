class ParticipantMailer < ApplicationMailer
  def attendance_reminder(person, activity)
    @person = person
    @activity = activity

    key = if activity.no_response_action # is true
            'activities.emails.attendance_reminder.subject_present'
          else
            'activities.emails.attendance_reminder.subject_absent'
          end

    subject = I18n.t(key, activity: @activity.name)

    mail(to: @person.email, subject: subject)
  end

  def subgroup_notification(person, activity, participant)
    @person = person
    @activity = activity

    @subgroup = participant.subgroup.name

    @others = participant
              .subgroup
              .participants
              .where.not(person: @person)
              .map { |pp| pp.person.full_name }
              .sort
              .join(', ')

    @subgroups = @activity
                 .subgroups
                 .order(name: :asc)

    @organizers = @activity
                  .organizer_names
                  .sort
                  .join(', ')

    subject = I18n.t('activities.emails.subgroup_notification.subject', subgroup: @subgroup, activity: @activity.name)

    mail(to: @person.email, subject: subject)
  end
end
