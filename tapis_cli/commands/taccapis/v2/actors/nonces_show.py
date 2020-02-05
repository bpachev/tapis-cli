from tapis_cli.display import Verbosity
from tapis_cli.search import SearchWebParam
from .mixins import ActorIdentifier

from . import API_NAME, SERVICE_VERSION
from .formatters import ActorsFormatOne
from .models import Nonce

__all__ = ['ActorsNoncesShow']


class ActorsNoncesShow(ActorsFormatOne, ActorIdentifier):
    """Get the details about a specific nonce for an actor
    """
    VERBOSITY = Verbosity.RECORD
    EXTRA_VERBOSITY = Verbosity.RECORD_VERBOSE

    def get_parser(self, prog_name):
        parser = super(ActorsNoncesShow, self).get_parser(prog_name)
        parser = ActorIdentifier.extend_parser(self, parser)
        parser.add_argument('nonceId',
                            metavar='<NONCE_ID>',
                            help='The id of the nonce')
        return parser

    def take_action(self, parsed_args):
        parsed_args = self.preprocess_args(parsed_args)
        actor_id = ActorIdentifier.get_identifier(self, parsed_args)
        nonce_id = parsed_args.nonceId
        rec = self.tapis_client.actors.getNonce(actorId=actor_id, nonceId=nonce_id)
        headers = self.render_headers(Nonce, parsed_args)
        data = []
        for key in headers:
            try:
                val = rec[key]
            except KeyError:
                val = None
            data.append(self.render_value(val))

        return (tuple(headers), tuple(data))
