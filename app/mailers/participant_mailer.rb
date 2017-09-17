class ParticipantMailer < ApplicationMailer
  def attendance_reminder(person, activity)
    @person = person
    @activity = activity

    subject = I18n.t('activities.emails.attendance_reminder.subject', activity: @activity.name)

    mail(to: @person.email, subject: subject)
  end
end
