<?php

namespace Psecio\Parse\Event;

use Symfony\Component\EventDispatcher\Event;

/**
 * Event containing a message
 */
class MessageEvent extends Event
{
    /**
     * @var string Message
     */
    private $message;

    /**
     * Set File and message
     *
     * @param string $message
     */
    public function __construct($message)
    {
        $this->message = $message;
    }

    /**
     * Get message
     *
     * @return string
     */
    public function getMessage()
    {
        return $this->message;
    }
}
