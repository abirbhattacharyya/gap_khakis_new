class Notification < ActionMailer::Base
  default_url_options[:host] = "dealkat.com"

  def forgot(user)
    subject    'Your forgotten password for Dealkat'
    recipients user.email
    from       sender_email

    body       :user => user
    sent_on    Time.now
#    content_type 'text/html'
  end

  def sendcoupon(recipient, payment)
    subject    'myprice coupon you requested'
    #recipients recipient
    bcc recipient
    from       sender_email
    reply_to   "custserv@gap.com"

    body      :payment => payment
    sent_on    Time.now
  end

  protected

  def sender_email
      '"GapMyPrice" <myprice@gapmyprice.com>'
  end
end
